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
