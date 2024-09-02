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
            
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(userID)
            
            db.runTransaction({ (transaction, errorPointer) -> Any? in
                do {
                    // 유저의 문서를 가져옴
                    let userDocument = try transaction.getDocument(userRef)
                    
                    // 현재 게시글 개수를 가져와서 1을 추가
                    let currentPostCount = userDocument.data()?["postCount"] as? Int ?? 0
                    transaction.updateData(["postCount": currentPostCount + 1], forDocument: userRef)
                    
                    // 썸네일 정보 저장
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
                    
                    let postRef = db.collection("posts").document(postID)
                    transaction.setData(thumbnailData, forDocument: postRef)
                    
                    // 상세 정보 저장
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
                    
                    let detailRef = postRef.collection("post_details").document(postID)
                    transaction.setData(postData, forDocument: detailRef)
                    
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
    //MARK: - 차단된 유저 확인 후, 해당 유저 게시물 제외한 나머지 게시물 불러오기
    func fetchAllPostThumbnails(forCurrentUser currentUserID: String, completion:@escaping (Result<[ThumbnailPostResponse], Error>) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("users").document(currentUserID).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let blockedUsers = document?.data()?["blockedUsers"] as? [String] else {
                // 차단된 유저가 없으면 모든 게시물 썸네일을 가져옴
                self.fetchThumbnailsExcludingBlockedUsers(blockedUsers:[],completion:completion)
                return
            }
            // 차단된 유저가 있는 경우 그 유저들을 제외한 게시물만 가져옴
            self.fetchThumbnailsExcludingBlockedUsers(blockedUsers: blockedUsers, completion: completion)
        }
    }
    
    private func fetchThumbnailsExcludingBlockedUsers(blockedUsers: [String],completion:@escaping (Result<[ThumbnailPostResponse],Error>)->Void) {
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
                    
                    // 차단된 유저의 게시물은 제외
                    if blockedUsers.contains(userID) {
                        continue
                    }
                    
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
    
    
    func fetchPostDetail(userID: String, postID: String, completion: @escaping (Result<PostDetailResponse, Error>) -> Void) {
        let postRef = db.collection("posts").document(postID)
        let userLikesRef = db.collection("users").document(userID).collection("likedPosts").document(postID)
        let userBookmarksRef = db.collection("users").document(userID).collection("bookmarkedPosts").document(postID)
     
        // Firestore에서 여러 문서를 병렬로 가져오는 DispatchGroup 사용
        let group = DispatchGroup()
        
        var postDetailResponse: PostDetailResponse?
        var isLiked: Bool = false
        var isBookmarked: Bool = false
        var fetchError: Error?
        
        group.enter()
        postRef.collection("post_details").document(postID).getDocument { (document, error) in
            defer { group.leave() }
            
            if let error = error {
                fetchError = error
                return
            }
            
            guard let data = document?.data() else {
                fetchError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data found for postID \(postID)"])
                return
            }
            
            if let postID = data["postID"] as? String,
               let userID = data["userID"] as? String,
               let title = data["title"] as? String,
               let content = data["content"] as? String,
               let imageURLs = data["imageURLs"] as? [String],
               let likeCount = data["likeCount"] as? Int,
               let commentCount = data["commentCount"] as? Int {
                
                let createdAt: Date?
                if let timestamp = data["createdAt"] as? Timestamp {
                    createdAt = timestamp.dateValue()
                } else {
                    createdAt = nil
                }
                
                postDetailResponse = PostDetailResponse(
                    postID: postID,
                    userID: userID,
                    title: title,
                    content: content,
                    imageURLs: imageURLs,
                    likeCount: likeCount,
                    commentCount: commentCount,
                    createdAt: createdAt,
                    isLiked: isLiked,
                    isBookmarked: isBookmarked
                )
            } else {
                fetchError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode data for postID \(postID)"])
            }
        }
        
        group.enter()
        userLikesRef.getDocument { (document, error) in
            defer { group.leave() }
            
            if let error = error {
                fetchError = error
                return
            }
            
            // 좋아요 여부 확인
            isLiked = document?.exists ?? false
        }
        
        group.enter()
          userBookmarksRef.getDocument { (document, error) in
              defer { group.leave() }
              
              if let error = error {
                  fetchError = error
                  return
              }
              
              // 북마크 여부 확인
              isBookmarked = document?.exists ?? false
          }
        
        // 모든 비동기 작업이 끝난 후에 실행
        group.notify(queue: .main) {
            if let fetchError = fetchError {
                completion(.failure(fetchError))
            } else if var postDetailResponse = postDetailResponse {
                postDetailResponse.isLiked = isLiked
                postDetailResponse.isBookmarked = isBookmarked
                completion(.success(postDetailResponse))
            } else {
                let noDataError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No post detail found for postID \(postID)"])
                completion(.failure(noDataError))
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
                      transaction.setData(["likedAt": FieldValue.serverTimestamp(), "postID": postID], forDocument: userLikesRef)
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
    
    // MARK: - 북마크 토글 함수
    func toggleBookmarkPost(userID: String, postID: String, completion: @escaping (Result<Bool, Error>) -> Void) {
      
        let userBookmarksRef = db.collection("users").document(userID).collection("bookmarkedPosts").document(postID)
        
        // Firestore 트랜잭션을 사용하여 북마크 토글 처리
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            do {
                let bookmarkDocument = try transaction.getDocument(userBookmarksRef)
                
                // 북마크가 이미 눌린 상태인지 확인
                let hasBookmarked = bookmarkDocument.exists
                
                if hasBookmarked {
                    // 북마크를 취소한 경우
                    transaction.deleteDocument(userBookmarksRef)
                } else {
                    // 북마크를 추가한 경우
                    transaction.setData(["createdAt": FieldValue.serverTimestamp(), "postID": postID], forDocument: userBookmarksRef)
                }
                
                return !hasBookmarked
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
    
    // MARK: - 특정 게시물이 북마크 상태인지 확인하는 함수
    func isPostBookmarked(userID: String, postID: String, completion: @escaping (Bool) -> Void) {
        let bookmarkRef = db.collection("users").document(userID).collection("bookmarkedPosts").document(postID)
        
        bookmarkRef.getDocument { document, error in
            if let error = error {
                print("Failed to check bookmark status: \(error.localizedDescription)")
                completion(false)  // 오류 발생 시 기본적으로 북마크 상태가 아님으로 설정
                return
            }
            
            // 문서가 존재하면 북마크된 상태임
            completion(document?.exists ?? false)
        }
    }

    //MARK: - 댓글 작성 함수
    func addComment(postID: String, userID: String, content: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let commentID = UUID().uuidString
        let createdAt = FieldValue.serverTimestamp()
        let postRef = db.collection("posts").document(postID)
        
        let commentData: [String: Any] = [
            "commentID": commentID,
            "postID": postID,
            "userID": userID,
            "content": content,
            "createdAt": createdAt,
            "likeCount": 0
        ]
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            // 현재 게시글을 가져옴
            let postDocument: DocumentSnapshot
            do {
                postDocument = try transaction.getDocument(postRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            // 댓글 수를 가져와 1을 추가
            let currentCommentCount = postDocument.data()?["commentCount"] as? Int ?? 0
            transaction.updateData(["commentCount": currentCommentCount + 1], forDocument: postRef)
            
            // 댓글 추가
            let commentRef = postRef.collection("comments").document(commentID)
            transaction.setData(commentData, forDocument: commentRef)
            
            return nil
        }) { (result, error) in
            if let error = error {
                print("Failed to add comment: \(error.localizedDescription)")
                completion(error)
            } else {
                print("댓글 추가 완료!!")
                completion(nil)
            }
        }
    }
    //MARK: - 댓글 불러오기 함수
    func fetchComments(forPost postID:String, completion: @escaping(Result<[CommentResponse],Error>) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("posts").document(postID).collection("comments")
            .order(by: "createdAt",descending: false)
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
    
    // MARK: - 댓글 삭제 함수
    func deleteComment(postID: String, commentID: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let postRef = db.collection("posts").document(postID)
        let commentRef = postRef.collection("comments").document(commentID)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            // 현재 게시글을 가져옴
            let postDocument: DocumentSnapshot
            do {
                postDocument = try transaction.getDocument(postRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            // 댓글 수를 가져와 1을 감소
            let currentCommentCount = postDocument.data()?["commentCount"] as? Int ?? 0
            transaction.updateData(["commentCount": max(currentCommentCount - 1, 0)], forDocument: postRef)
            
            // 댓글 삭제
            transaction.deleteDocument(commentRef)
            
            return nil
        }) { (result, error) in
            if let error = error {
                print("Failed to delete comment: \(error.localizedDescription)")
                completion(error)
            } else {
                print("댓글 삭제 완료!!")
                completion(nil)
            }
        }
    }


    // MARK: - 댓글 수정 함수
    
    func updateComment(postID: String, commentID: String, newContent: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let commentRef = db.collection("posts").document(postID).collection("comments").document(commentID)
        
        // content 필드를 새 내용으로 업데이트
        commentRef.updateData(["content": newContent]) { error in
            if let error = error {
                print("Error updating comment: \(error.localizedDescription)")
                completion(error)
            } else {
                print("댓글 업데이트 완료!!")
                completion(nil)
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

extension CommunityService {
    // MARK: - 커뮤니티 게시글 수정 함수 구현
    func updatePost(postID: String, userID: String, newTitle: String?, newContent: String?, newImages: [Data]?, existingImageURLs: [String]?, removedImageURLs: [String]?, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let postRef = db.collection("posts").document(postID)
        let detailRef = postRef.collection("post_details").document(postID)
        let storageRef = Storage.storage().reference()
        
        var newImageURLs: [String] = existingImageURLs ?? []
        var errors: [Error] = []
        let group = DispatchGroup()
        
        // 1. 새로 추가된 이미지를 Firebase Storage에 업로드
        if let newImages = newImages {
            for imageData in newImages {
                let fileName = UUID().uuidString + ".jpg"
                let fileRef = storageRef.child("community_images/\(fileName)")
                
                group.enter()
                fileRef.putData(imageData, metadata: nil) { _, error in
                    if let error = error {
                        errors.append(error)
                        group.leave()
                        return
                    }
                    
                    fileRef.downloadURL { url, error in
                        if let error = error {
                            errors.append(error)
                        } else if let url = url {
                            newImageURLs.append(url.absoluteString)
                        }
                        group.leave()
                    }
                }
            }
        }
        // 2. 기존에 있던 이미지 중 삭제된 이미지를 Firebase Storage에서 삭제
        if let removedImageURLs = removedImageURLs {
            for imageURL in removedImageURLs {
                guard let fileName = extractFileName(from: imageURL) else { continue }
                let fileRef = storageRef.child("community_images/\(fileName)")
                
                group.enter()
                fileRef.delete { error in
                    if let error = error {
                        errors.append(error)
                    } else {
                        // 삭제된 이미지를 목록에서 제거
                        newImageURLs.removeAll { $0 == imageURL }
                    }
                    group.leave()
                }
            }
        }
        // 3. 모든 작업이 완료되면 Firestore 업데이트
        group.notify(queue: .main) {
            if !errors.isEmpty {
                completion(errors.first)
                return
            }
            
            // 4. 썸네일 이미지 설정
            let newThumbnailURL = newImageURLs.first ?? ""
            
            var updatedData: [String: Any] = [:]
            if let newTitle = newTitle {
                updatedData["title"] = newTitle
            }
            if let newContent = newContent {
                updatedData["content"] = newContent
            }
            updatedData["imageURLs"] = newImageURLs
            updatedData["thumbnail"] = newThumbnailURL  // 썸네일 업데이트
            updatedData["updatedAt"] = FieldValue.serverTimestamp()
            
            // 5. Firestore 업데이트
            detailRef.updateData(updatedData) { error in
                if let error = error {
                    completion(error)
                    return
                }
                // 썸네일 문서도 업데이트
                postRef.updateData(["thumbnail": newThumbnailURL]) { error in
                    completion(error)
                }
            }
        }
    }
    
    private func extractFileName(from url: String) -> String? {
        guard let urlComponents = URLComponents(string: url),
              let queryItems = urlComponents.queryItems,
              let path = urlComponents.path.removingPercentEncoding else {
            return nil
        }
        
        let pathComponents = path.split(separator: "/")
        return pathComponents.last?.components(separatedBy: "%2F").last
    }
    
}

extension CommunityService {
    // MARK: - 게시글 삭제 함수
    
    func deletePost(postID: String, userID: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let postRef = db.collection("posts").document(postID)
        let detailRef = postRef.collection("post_details").document(postID)  // 여기서 imageURLs 접근
        let userRef = db.collection("users").document(userID)
        let commentsCollection = postRef.collection("comments")
        let likesCollection = db.collectionGroup("likedPosts").whereField("postID", isEqualTo: postID)
        let bookmarksCollection = db.collectionGroup("bookmarkedPosts").whereField("postID", isEqualTo: postID)
        let storageRef = Storage.storage().reference()
        
        // 트랜잭션 외부에서 먼저 댓글, 좋아요, 북마크를 가져옴
        commentsCollection.getDocuments { (commentSnapshot, error) in
            if let error = error {
                completion(error)
                return
            }
            
            likesCollection.getDocuments { (likesSnapshot, error) in
                if let error = error {
                    completion(error)
                    return
                }
                
                bookmarksCollection.getDocuments { (bookmarksSnapshot, error) in
                    if let error = error {
                        completion(error)
                        return
                    }
                    
                    // 필요한 데이터를 읽어온 후, 트랜잭션을 시작
                    db.runTransaction({ (transaction, errorPointer) -> Any? in
                        do {
                            // 게시글 상세 정보 문서 가져오기
                            let detailDocument = try transaction.getDocument(detailRef)
                            guard let detailData = detailDocument.data() else {
                                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No detail data found for postID \(postID)"])
                            }
                            
                            // `imageURLs` 값 디버깅
                            print("Detail Data:", detailData)  // detailData 내용 전체 출력
                            let imageURLs = detailData["imageURLs"] as? [String] ?? []
                            print("imageURLs from detailData:", imageURLs)  // `imageURLs` 값 출력
                            
                            // 작성자 정보 업데이트: postCount 감소
                            let userDocument = try transaction.getDocument(userRef)
                            let currentPostCount = userDocument.data()?["postCount"] as? Int ?? 0
                            transaction.updateData(["postCount": max(currentPostCount - 1, 0)], forDocument: userRef)
                            
                            // 3. 썸네일 및 상세 정보 문서 삭제
                            transaction.deleteDocument(detailRef)
                            transaction.deleteDocument(postRef)
                            
                            // 4. 삭제할 이미지 URL 반환
                            return imageURLs
                            
                        } catch let error {
                            errorPointer?.pointee = error as NSError
                            return nil
                        }
                    }) { (result, error) in
                        if let error = error {
                            print("Failed to delete post: \(error.localizedDescription)")
                            completion(error)
                        } else {
                            print("게시글 삭제 완료!")
                            
                            // 트랜잭션 외부에서 각 문서 및 이미지 삭제 작업 수행
                            
                            // 댓글 삭제
                            for commentDocument in commentSnapshot?.documents ?? [] {
                                commentDocument.reference.delete { error in
                                    if let error = error {
                                        print("Error deleting comment: \(error.localizedDescription)")
                                    }
                                }
                            }
                            
                            // 좋아요 정보 삭제
                            for likeDocument in likesSnapshot?.documents ?? [] {
                                likeDocument.reference.delete { error in
                                    if let error = error {
                                        print("Error deleting like: \(error.localizedDescription)")
                                    }
                                }
                            }
                            
                            // 북마크 정보 삭제
                            for bookmarkDocument in bookmarksSnapshot?.documents ?? [] {
                                bookmarkDocument.reference.delete { error in
                                    if let error = error {
                                        print("Error deleting bookmark: \(error.localizedDescription)")
                                    }
                                }
                            }
                            
                            // 이미지 삭제
                            if let imageURLs = result as? [String] {
                                for imageURL in imageURLs {
                                    print("Attempting to delete image from URL: \(imageURL)")  // 디버깅: 이미지 URL 출력
                                    
                                    if let fileName = self.extractFileName(from: imageURL) {
                                        let fileRef = storageRef.child("community_images/\(fileName)")
                                        print("Extracted file name: \(fileName) - Full path: \(fileRef.fullPath)")  // 디버깅: 경로 출력
                                        
                                        fileRef.delete { error in
                                            if let error = error {
                                                print("Error deleting image: \(error.localizedDescription)")
                                            } else {
                                                print("Successfully deleted image: \(imageURL)")
                                            }
                                        }
                                    } else {
                                        print("Failed to extract file name from URL: \(imageURL)")
                                    }
                                }
                            }
                            
                            completion(nil)
                        }
                    }
                }
            }
        }
    }
}
