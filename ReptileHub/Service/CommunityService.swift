//
//  CommunityService.swift
//  ReptileHub
//
//  Created by 임재현 on 8/13/24.
//

import Firebase
import FirebaseStorage
import FirebaseFirestore

class CommunityService {
   
    static let shared = CommunityService()
    private init() {}
    private let db = Firestore.firestore()
    private let storageRef = Storage.storage().reference()

    //MARK: - 커뮤니티 게시글 작성 후 등록 함수
    func createPost(userID: String, title: String, content: String, images: [Data], completion: @escaping (Error?) -> Void) {
           uploadImages(images: images) { urls, errors in
               if let errors = errors, !errors.isEmpty {
                   completion(errors.first)
                   return
               }
               
               guard let urls = urls else {
                   completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to upload images"]))
                   return
               }
               
               let postID = UUID().uuidString
               let previewContent = String(content.prefix(40))
               
              
              
               // 1. 썸네일 정보
               let thumbnailData: [String: Any] = [
                   "postID": postID,
                   "userID": userID,
                   "thumbnail": urls.first ?? "", // 첫 번째 이미지를 썸네일로 사용
                   "title": title,
                   "previewContent": previewContent,
                   "createdAt": FieldValue.serverTimestamp(),
                   "likeCount": 0,
                   "commentCount": 0
        
               ]
               // 2. 썸네일 정보 저장
               self.db.collection("posts").document(postID).collection("post_thumbnails").document(postID).setData(thumbnailData) { error in
                   if let error = error {
                       completion(error)
                       return
                   }
               }
               
               // 3. 상세 정보
               let postData: [String: Any] = [
                   "postID": postID,
                   "userID": userID,
                   "title": title,
                   "content": content,
                   "imageURLs": urls,
                   "createdAt": FieldValue.serverTimestamp(),
                   "likeCount": 0,
                   "commentCount": 0
               ]
               
               // 4. 상세 정보 저장
               self.db.collection("posts").document(postID).collection("post_details").document(postID).setData(postData) { error in
                   completion(error)
               }
           }
       }
       

}


extension CommunityService {
    private func uploadImage(imageData: Data, completion: @escaping (String?, Error?) -> Void) {
           let filePath = "community_images/\(UUID().uuidString).jpg"
           let metaData = StorageMetadata()
           metaData.contentType = "image/jpeg"
           
           storageRef.child(filePath).putData(imageData) { metaData, error in
               if let error = error {
                   completion(nil, error)
                   return
               }
               self.storageRef.child(filePath).downloadURL { url, error in
                   completion(url?.absoluteString, error)
               }
           }
       }
       
       // 여러 이미지를 업로드하는 함수 -> 성공 시 각각의 url 배열 리턴, 실패 시 errors 배열 리턴
       private func uploadImages(images: [Data], completion: @escaping ([String]?, [Error]?) -> Void) {
           let group = DispatchGroup()
           var urls = [String]()
           var errors = [Error]()
           
           for imageData in images {
               group.enter()
               uploadImage(imageData: imageData) { url, error in
                   if let error = error {
                       errors.append(error)
                   }
                   if let url = url {
                       urls.append(url)
                   }
                   group.leave()
               }
           }
           
           group.notify(queue: .main) {
               completion(urls.isEmpty ? nil : urls, errors.isEmpty ? nil : errors)
           }
       }
}
