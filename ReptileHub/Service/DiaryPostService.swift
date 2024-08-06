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
    func createDiary(diary:DiaryRequest,selfImageData:Data?
                     ,motherImageData:Data?,fatherImageData:Data?,completion: @escaping(Error?)->Void) {
        
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
            updateDiary.imageURL = urls[0]
            
            if var parentInfo = updateDiary.parentInfo {
                parentInfo.mother.imageURL = urls[1]
                parentInfo.father.imageURL = urls[2]
                updateDiary.parentInfo = parentInfo
            }
            
            do {
                let diaryData = try JSONEncoder().encode(updateDiary)
                let dictionary = try JSONSerialization.jsonObject(with: diaryData, options: []) as? [String:Any]
                self.db.collection("diaries").addDocument(data: dictionary ?? [:]) { error in
                    completion(error)
                }
            } catch {
                completion(error)
            }
            
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
