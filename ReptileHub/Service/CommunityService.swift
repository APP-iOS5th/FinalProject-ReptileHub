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
               self.db.collection("posts").document(postID).setData(thumbnailData) { error in
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
       
    func fetchAllPostThumbnails(completion:@escaping (Result<[ThumbnailPostResponse],Error>)->Void) {
        let db = Firestore.firestore()
        
        // 'posts' 컬렉션에서 모든 문서를 가져옴
        db.collection("posts").getDocuments { querySnapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            var thumbnails: [ThumbnailPostResponse] = []
            
            // 각 문서의 썸네일 정보를 수집
            for document in querySnapshot?.documents ?? [] {
                let data = document.data()
                
                if let postID = data["postID"] as? String,
                   let title = data["title"] as? String,
                   let userID = data["userID"] as? String,
                   let thumbnailURL = data["thumbnail"] as? String,
                   let previewContent = data["previewContent"] as? String,
                   let likeCount = data["likeCount"] as? Int,
                   let commentCount = data["commentCount"] as? Int,
                   let createdAt = data["createdAt"] as? Timestamp {
                    
                    //받아온 정보로 객체 생성
                    let thumbnailResponse = ThumbnailPostResponse(
                        postID: postID,
                        title: title,
                        userID: userID,
                        thumbnailURL: thumbnailURL,
                        previewContent: previewContent,
                        likeCount: likeCount,
                        commentCount: commentCount,
                        createdAt: createdAt.dateValue()
                    )
                    thumbnails.append(thumbnailResponse)
                }
                
            }
           // completion으로 전송
            completion(.success(thumbnails))
            
        }
    }
    
    func fetchPostDetail(postID: String, completion: @escaping (Result<PostDetailResponse, Error>) -> Void) {
        db.collection("posts")
            .document(postID)
            .collection("post_details")
            .document(postID)
            .getDocument { (document, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = document?.data() else {
                    let noDataError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data found for postID \(postID)"])
                    completion(.failure(noDataError))
                    return
                }
                
                // 데이터 추출 및 PostDetailResponse 객체 생성
                if let postID = data["postID"] as? String,
                   let userID = data["userID"] as? String,
                   let title = data["title"] as? String,
                   let content = data["content"] as? String,
                   let imageURLs = data["imageURLs"] as? [String],
                   let likeCount = data["likeCount"] as? Int,
                   let commentCount = data["commentCount"] as? Int {
                    
                    // createdAt 필드 처리
                    let createdAt: Date?
                    if let timestamp = data["createdAt"] as? Timestamp {
                        createdAt = timestamp.dateValue()
                    } else {
                        createdAt = nil // createdAt 필드가 없을 경우 nil로 처리
                    }
                    
                    let postDetailResponse = PostDetailResponse(
                        postID: postID,
                        userID: userID,
                        title: title,
                        content: content,
                        imageURLs: imageURLs,
                        likeCount: likeCount,
                        commentCount: commentCount,
                        createdAt: createdAt
                    )
                    
                    completion(.success(postDetailResponse))
                } else {
                    let decodeError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode data for postID \(postID)"])
                    completion(.failure(decodeError))
                }
            }
    }
    
    //MARK: - 좋아요, 좋아요 취소 토글 버튼
    func toggleLikePost(userID: String, postID: String, completion: @escaping (Result<Bool, Error>) -> Void) {
          let postRef = db.collection("posts").document(postID)
          let userLikesRef = db.collection("users").document(userID).collection("likedPosts").document(postID)
          
          // Firestore 트랜잭션을 사용하여 좋아요 토글 처리
          db.runTransaction({ (transaction, errorPointer) -> Any? in
              do {
                  let postDocument = try transaction.getDocument(postRef)
                  let userLikesDocument = try transaction.getDocument(userLikesRef)
                  
                  // 좋아요가 이미 눌린 상태인지 확인
                  let hasLiked = userLikesDocument.exists
                  
                  // 좋아요 상태에 따라 likeCount 업데이트
                  let likeCount = postDocument.data()?["likeCount"] as? Int ?? 0
                  let newLikeCount = hasLiked ? likeCount - 1 : likeCount + 1
                  
                  // 좋아요 상태 업데이트
                  transaction.updateData(["likeCount": newLikeCount], forDocument: postRef)
                  
                  if hasLiked {
                      // 좋아요를 취소한 경우
                      transaction.deleteDocument(userLikesRef)
                  } else {
                      // 좋아요를 추가한 경우
                      transaction.setData(["likedAt": FieldValue.serverTimestamp()], forDocument: userLikesRef)
                  }
                  
                  return !hasLiked
              } catch {
                  errorPointer?.pointee = error as NSError
                  return nil
              }
          }) { (result, error) in
              if let error = error {
                  completion(.failure(error))
              } else if let success = result as? Bool {
                  completion(.success(success))
              }
          }
      }
    
    //MARK: - 댓글 작성 함수
    func addComment(postID:String,userID:String,content:String,completion:@escaping(Error?)->Void) {
        let db = Firestore.firestore()
        let commentID = UUID().uuidString
        let createdAt = FieldValue.serverTimestamp()
        
        let commentData : [String:Any] = [
            "commentID" : commentID,
            "postID" : postID,
            "userID" : userID,
            "content" : content,
            "createdAt" : createdAt,
            "likeCount" : 0
        ]
        db.collection("posts").document(postID).collection("comments").document(commentID).setData(commentData) { error in
            completion(error)
        }
    }
    
    //MARK: - 댓글 불러오기 함수
    func fetchComments(forPost postID:String, completion: @escaping(Result<[CommentResponse],Error>) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("posts").document(postID).collection("comments")
            .order(by: "createdAt",descending: true)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                var comments: [CommentResponse] = []
                
                for document in querySnapshot?.documents ?? [] {
                    let data = document.data()
                    
                    if let commentID = data["commentID"] as? String,
                       let postID = data["postID"] as? String,
                       let userID = data["userID"] as? String,
                       let content = data["content"] as? String,
                       let likeCount = data["likeCount"] as? Int,
                       let createdAt = data["createdAt"] as? Timestamp {
                        
                        let comment = CommentResponse(
                            commentID: commentID,
                            postID: postID,
                            userID: userID,
                            content: content,
                            createdAt: createdAt.dateValue(),
                            likeCount: likeCount
                        )
                        comments.append(comment)
                    }
                }
                
                completion(.success(comments))
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
