//
//  DiaryPostService.swift
//  ReptileHub
//
//  Created by 임재현 on 8/5/24.
//

import Firebase
import FirebaseFirestore
import FirebaseStorage

class DiaryPostService {
    
    private let db = Firestore.firestore()
    private let storageRef = Storage.storage().reference()
    
    static let shared = DiaryPostService()
    private init() {}
    
    
    //MARK: - 작성완료 버튼 누를 시 FireStore 에 해당 정보 저장, ImagePicker 에서 나, 엄마 , 아빠 사진 각각 받아서 파라미터에 할당하면 됨 / 프로필에 등록된 도마뱀 개수 +1
    func registerGrowthDiary(userID: String, diary: GrowthDiaryRequest, selfImageData: Data?,
                             motherImageData: Data?, fatherImageData: Data?,
                             completion: @escaping (Error?) -> Void) {

        let imageDatas: [Data?] = [selfImageData, motherImageData, fatherImageData]
        let group = DispatchGroup()
        var urls = [String?](repeating: nil, count: imageDatas.count)
        var errors = [Error]()
        
        for (index, imageData) in imageDatas.enumerated() {
            guard let imageData = imageData else { continue }
            group.enter()
            uploadImage(imageData: imageData) { url, error in
                if let error = error {
                    errors.append(error)
                }
                urls[index] = url
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if !errors.isEmpty {
                completion(errors.first)
                return
            }
            
            var updateDiary = diary
            updateDiary.lizardInfo.imageURL = urls[0]
            
            if var parentInfo = updateDiary.parentInfo {
                parentInfo.mother.imageURL = urls[1]
                parentInfo.father.imageURL = urls[2]
                updateDiary.parentInfo = parentInfo
            }
            
            let db = Firestore.firestore()
            let profileRef = db.collection("users").document(userID)
            let diaryID = UUID().uuidString  // 고유 ID 생성
            
            db.runTransaction({ (transaction, errorPointer) -> Any? in
                do {
                    let profileDocument = try transaction.getDocument(profileRef)
                    
                    // 현재 도마뱀 개수를 가져와서 1을 추가
                    let currentLizardCount = profileDocument.data()?["lizardCount"] as? Int ?? 0
                    transaction.updateData(["lizardCount": currentLizardCount + 1], forDocument: profileRef)
                    
                    // 썸네일 정보 저장
                    let thumbnailData: [String: Any] = [
                        "diary_id": diaryID,
                        "thumbnail": updateDiary.lizardInfo.imageURL as Any,
                        "name": updateDiary.lizardInfo.name
                    ]
                    
                    let thumbnailRef = db.collection("users").document(userID)
                        .collection("growth_diaries_thumbnails").document(diaryID)
                    transaction.setData(thumbnailData, forDocument: thumbnailRef)
                    
                    // 상세 정보 저장
                    let diaryData = try JSONEncoder().encode(updateDiary)
                    let dictionary = try JSONSerialization.jsonObject(with: diaryData, options: []) as? [String: Any]
                    
                    let detailRef = db.collection("users").document(userID)
                        .collection("growth_diaries_details").document(diaryID)
                    transaction.setData(dictionary ?? [:], forDocument: detailRef)
                    
                    return nil
                } catch {
                    errorPointer?.pointee = error as NSError
                    return nil
                }
            }) { (result, error) in
                if let error = error {
                    completion(error)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    //MARK: - 성장일기 썸네일 정보 불러오는 함수, 이미지, 제목, diaryID가 내려와, 해당 diaryID로 detail 검색 가능
    func fetchGrowthThumbnails(for userID: String, completion: @escaping (Result<[ThumbnailResponse], Error>) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("users").document(userID)
            .collection("growth_diaries_thumbnails")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching thumbnails: \(error.localizedDescription)")
                    completion(.failure(error))  // 오류가 발생한 경우, 오류를 반환
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    completion(.success([]))  // 문서가 없으면 빈 배열을 반환
                    return
                }

                var thumbnails: [ThumbnailResponse] = []
                
                for document in documents {
                    let data = document.data()
                    if let diaryID = data["diary_id"] as? String,
                       let thumbnail = data["thumbnail"] as? String,
                       let name = data["name"] as? String {
                        let thumbnailData = ThumbnailResponse(diary_id: diaryID, thumbnail: thumbnail, name: name)
                        thumbnails.append(thumbnailData)
                    }
                }
                
                completion(.success(thumbnails))  // 성공적으로 썸네일 데이터를 반환
            }
    }
    
    //MARK: - DiaryDetail 정보 불러오는 함수. 썸네일에서 받아온 diaryID 를 할당해서 조회 하면 해당 detail 정보를 받을 수 있다 .
    func fetchGrowthDiaryDetails(userID: String, diaryID: String, completion: @escaping (GrowthDiaryResponse?) -> Void) {
        db.collection("users").document(userID)
            .collection("growth_diaries_details")
            .document(diaryID)
            .getDocument { (document, error) in
                if let error = error {
                    print("Error getting document: \(error)")
                    completion(nil)
                    return
                }
                
                guard let document = document, document.exists else {
                    print("Document does not exist")
                    completion(nil)
                    return
                }
                
                print("Document data: \(document.data() ?? [:])")  // Document의 데이터 확인
                if let diaryResponse = try? document.data(as: GrowthDiaryResponse.self) {
                    completion(diaryResponse)
                } else {
                    print("Failed to decode DiaryResponse")  // 디코딩 실패 여부 확인
                    completion(nil)
                }
            }
    }
    
    //MARK: - 성장일지 삭제 - 등록된 도마뱀 삭제시 -> 썸네일, detail, 성장일기 및 관련 image Storage 에서 삭제 및 프로필에 등록된 도마뱀 개수 -1
    func deleteGrowthDiary(userID: String, diaryID: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let profileRef = db.collection("users").document(userID)
        let thumbnailRef = profileRef.collection("growth_diaries_thumbnails").document(diaryID)
        let detailRef = profileRef.collection("growth_diaries_details").document(diaryID)
        let storageRef = Storage.storage().reference()

        // 1. 하위 컬렉션인 diaryEntries 삭제
        let entriesRef = detailRef.collection("diary_entries")
        entriesRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching diary entries: \(error.localizedDescription)")
                completion(error)
                return
            }
            
            let batch = db.batch()
            
            for document in querySnapshot?.documents ?? [] {
                let data = document.data()
                
                // diaryEntry에 저장된 이미지 URL들 삭제
                if let imageURLs = data["imageURLs"] as? [String] {
                    for imageURL in imageURLs {
                        print("Attempting to delete image from URL: \(imageURL)")
                        self.deleteImage(from: imageURL) { error in
                            if let error = error {
                                print("Error deleting image from diary entry: \(error.localizedDescription)")
                            } else {
                                print("Successfully deleted image: \(imageURL)")
                            }
                        }
                    }
                }
                
                // 하위 컬렉션의 모든 문서를 삭제
                batch.deleteDocument(document.reference)
            }
            
            // 2. 썸네일 이미지 삭제
            thumbnailRef.getDocument { (document, error) in
                if let data = document?.data(),
                   let thumbnailURL = data["thumbnail"] as? String {
                    print("Attempting to delete thumbnail image from URL: \(thumbnailURL)")
                    self.deleteImage(from: thumbnailURL) { error in
                        if let error = error {
                            print("Error deleting thumbnail: \(error.localizedDescription)")
                        } else {
                            print("Successfully deleted thumbnail image: \(thumbnailURL)")
                        }
                    }
                }
            }
            
            // 3. 부모 문서와 관련된 썸네일 및 상세 정보 문서 삭제
            detailRef.getDocument { (document, error) in
                if let data = document?.data() {
                    // 부모 정보에 저장된 이미지 URL 삭제
                    if let parentInfo = data["parentInfo"] as? [String: Any] {
                        if let motherInfo = parentInfo["mother"] as? [String: Any],
                           let motherImageURL = motherInfo["imageURL"] as? String {
                            print("Attempting to delete mother image from URL: \(motherImageURL)")
                            self.deleteImage(from: motherImageURL) { error in
                                if let error = error {
                                    print("Error deleting mother image: \(error.localizedDescription)")
                                } else {
                                    print("Successfully deleted mother image: \(motherImageURL)")
                                }
                            }
                        }
                        
                        if let fatherInfo = parentInfo["father"] as? [String: Any],
                           let fatherImageURL = fatherInfo["imageURL"] as? String {
                            print("Attempting to delete father image from URL: \(fatherImageURL)")
                            self.deleteImage(from: fatherImageURL) { error in
                                if let error = error {
                                    print("Error deleting father image: \(error.localizedDescription)")
                                } else {
                                    print("Successfully deleted father image: \(fatherImageURL)")
                                }
                            }
                        }
                    }
                }
                
                batch.deleteDocument(thumbnailRef)
                batch.deleteDocument(detailRef)
                
                // 4. 배치 작업 커밋
                batch.commit { error in
                    if let error = error {
                        print("Error committing batch delete: \(error.localizedDescription)")
                        completion(error)
                    } else {
                        // 5. 도마뱀 개수 감소 트랜잭션
                        db.runTransaction({ (transaction, errorPointer) -> Any? in
                            do {
                                let profileDocument = try transaction.getDocument(profileRef)
                                let currentLizardCount = profileDocument.data()?["lizardCount"] as? Int ?? 0
                                
                                if currentLizardCount > 0 {
                                    transaction.updateData(["lizardCount": currentLizardCount - 1], forDocument: profileRef)
                                }
                                
                                return nil
                            } catch {
                                errorPointer?.pointee = error as NSError
                                return nil
                            }
                        }) { (result, error) in
                            if let error = error {
                                print("Error in lizard count transaction: \(error.localizedDescription)")
                                completion(error)
                            } else {
                                print("Successfully deleted growth diary and updated lizard count")
                                completion(nil)
                            }
                        }
                    }
                }
            }
        }
    }
}

extension DiaryPostService {
   
    //MARK: - 성장 일지 속 일기 작성 함수
    func createDiary(userID: String, diaryID: String, images: [Data], title: String, content: String, completion: @escaping (Error?) -> Void) {
        uploadImages(images: images) { urls, errors in
            if let errors = errors, !errors.isEmpty {
                completion(errors.first)
                return
            }
            
            guard let urls = urls else {
                completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to upload images"]))
                return
            }
            
            let diaryRequest = DiaryRequest(title: title, content: content, imageURLs: urls)
            
            let diaryData: [String: Any] = [
                "title": diaryRequest.title,
                "content": diaryRequest.content,
                "imageURLs": diaryRequest.imageURLs,
                "createdAt": FieldValue.serverTimestamp()
            ]
            
            let db = Firestore.firestore()
            db.collection("users").document(userID)
                .collection("growth_diaries_details").document(diaryID)
                .collection("diary_entries").addDocument(data: diaryData) { error in
                    completion(error)
                }
        }
    }

    //MARK: - 성장 일지 속 일기 불러오기 - limit 로 개수 조정 가능
    func fetchDiaryEntries(userID: String, diaryID: String, limit: Int? = nil, completion: @escaping (Result<[DiaryResponse], Error>) -> Void) {
        let db = Firestore.firestore()
        
        var query: Query = db.collection("users").document(userID)
            .collection("growth_diaries_details").document(diaryID)
            .collection("diary_entries")
            .order(by: "createdAt", descending: true)
        
        // limit 파라미터가 제공된 경우 쿼리에 제한 추가
        if let limit = limit {
            query = query.limit(to: limit)
        }
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                completion(.success([]))
                return
            }

            var diaryEntries: [DiaryResponse] = []
            
            for document in documents {
                if let diaryEntry = try? document.data(as: DiaryResponse.self) {
                    diaryEntries.append(diaryEntry)
                }
            }
            
            completion(.success(diaryEntries))
        }
    }

    
}



extension DiaryPostService {
    
    //MARK: - 선택된 이미지 데이터를 Storage 에 저장하는 함수 -> completion으로 성공시 url 리턴, 실패시 error 리턴
    private func uploadImage(imageData:Data, completion: @escaping (String?,Error?)-> Void) {
        let filePath = "images/\(UUID().uuidString).jpg"
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        storageRef.child(filePath).putData(imageData) { metaData, error in
            if let error = error {
                completion(nil,error)
                return
            }
            self.storageRef.child(filePath).downloadURL { url, error in
                completion(url?.absoluteString,error)
            }
        }
    }
    
    //MARK: - 선택한 이미지 배열을 하나하나 uploadImage로 보내는 함수 ->
    private func uploadImages(images:[Data], completion:@escaping([String]?,[Error]?)->Void) {
        let group = DispatchGroup()
        var urls = [String]()
        var errors = [Error]()
        
        for imageData in images {
            
            // 비동기 작업 시작
            group.enter()
            uploadImage(imageData: imageData) { url, error in
                if let error = error {
                    errors.append(error)
                }
                
                if let url = url {
                    urls.append(url)
                }
                // 비동기 작업 끝
                group.leave()
            }
        }
        
        //작업 완료시 실행 -> 콜백함수 파라미터 전달
        group.notify(queue: .main) {
            completion(urls.isEmpty ? nil : urls, errors.isEmpty ? nil : errors)
        }
        
    }
    //MARK: -  이미지URL -> FireStorage 저장된 이미지 명 변환하는 함수
    private func extractFileName(from url: String) -> String? {
        guard let urlComponents = URLComponents(string: url),
              let queryItems = urlComponents.queryItems,
              let path = urlComponents.path.removingPercentEncoding else {
            return nil
        }

        let pathComponents = path.split(separator: "/")
        return pathComponents.last?.components(separatedBy: "%2F").last
    }

    //MARK: -FireStorage 에서 해당 경로의 이미지 파일명 삭제 함수
    func deleteImage(from url: String, completion: @escaping (Error?) -> Void) {
        guard let fileName = extractFileName(from: url) else {
            print("Invalid file URL: \(url)")
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid file URL"]))
            return
        }
        
        let fileRef = Storage.storage().reference().child("images/\(fileName)")
        print("Deleting file at path: \(fileRef.fullPath)")
        fileRef.delete { error in
            if let error = error {
                print("Error deleting file at path: \(fileRef.fullPath) - \(error.localizedDescription)")
            } else {
                print("Successfully deleted file at path: \(fileRef.fullPath)")
            }
            completion(error)
        }
    }
}
