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
    
    
    //MARK: - 작성완료 버튼 누를 시 FireStore 에 해당 정보 저장, ImagePicker 에서 나, 엄마 , 아빠 사진 각각 받아서 파라미터에 할당하면 됨
    func registerGrowthDiary(userID:String,diary:GrowthDiaryRequest,selfImageData:Data?
                             ,motherImageData:Data?,fatherImageData:Data?,
                             completion: @escaping(Error?)->Void) {
        
        let imageDatas: [Data?] = [selfImageData,motherImageData,fatherImageData]
        let group = DispatchGroup()
        var urls = [String?](repeating: nil, count: imageDatas.count)
        var errors = [Error]()
        
        for (index, imageData) in imageDatas.enumerated() {
            guard let imageData = imageData else {continue}
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
            
            do {
                let diaryData = try JSONEncoder().encode(updateDiary)
                let dictionary = try JSONSerialization.jsonObject(with: diaryData, options: []) as? [String:Any]
                
                let diaryID = UUID().uuidString
                
                // 1. 썸네일 정보 저장
                let thumbnailData: [String: Any] = [
                    "diary_id": diaryID,
                    "thumbnail": updateDiary.lizardInfo.imageURL as Any,
                    "name": updateDiary.lizardInfo.name
                ]
                
                self.db.collection("users").document(userID)
                    .collection("growth_diaries_thumbnails")
                    .document(diaryID)
                    .setData(thumbnailData) { error in
                        if let error = error {
                            completion(error)
                            return
                        }
                    }
                
                // 2. 상세 정보 저장
                self.db.collection("users").document(userID)
                    .collection("growth_diaries_details")
                    .document(diaryID)
                    .setData(dictionary ?? [:]) { error in
                        completion(error)
                        
                    }
            } catch {
                completion(error)
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
    
    //MARK: - diary 삭제 - 추후 검증 필요 ( do - catch 사용 여부 관련)
    func deleteDiary(documentId: String, completion: @escaping (Error?) -> Void) {
           db.collection("diaries").document(documentId).delete() { error in
               completion(error)
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
    
    // 선택된 이미지 데이터를 Storage 에 저장하는 함수 -> completion으로 성공시 url 리턴, 실패시 error 리턴
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
    
    // 선택한 이미지 배열을 하나하나 uploadImage로 보내는 함수 ->
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
}
