//
//  UserService.swift
//  ReptileHub
//
//  Created by 임재현 on 8/16/24.
//

import Firebase
import FirebaseFirestore
import FirebaseStorage

class UserService {
    static let shared = UserService()
    private init() {}
    //MARK: - 유저 차단 기능
    func blockUser(currentUserID: String,blockUserID: String, completion:@escaping (Error?)-> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUserID)
        
        userRef.updateData(["blockedUsers" : FieldValue.arrayUnion([blockUserID])]) { error in
            completion(error)
        }
    }
    
    //MARK: - 유저 차단해제 기능
    func unblockUser(currentUserID: String, unBlockUserID: String, completion:@escaping (Error?)->Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUserID)
        
        userRef.updateData(["blockedUsers": FieldValue.arrayRemove([unBlockUserID])]) { error in
            completion(error)
        }
    }
    
    //MARK: - 차단된 유저 프로필 불러오기
    func fetchBlockUsers(currentUserID: String, completion: @escaping(Result<[BlockUserProfile],Error>)->Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUserID)
        
        userRef.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let blockedUserIDs = document?.data()?["blockedUsers"] as? [String] else {
                completion(.success([]))
                return
            }
            
            let group = DispatchGroup()
            var blockedUsers: [BlockUserProfile] = []
            var fetchError:Error?
            
            for userID in blockedUserIDs {
                group.enter()
                
                db.collection("users").document(userID).getDocument { userDocument, error in
                    if let error = error {
                        fetchError = error
                    } else if let userData = userDocument?.data(),
                              let name = userData["name"] as? String,
                              let profileImageURL = userData["profileImageURL"] as? String {
                        let userProfile = BlockUserProfile(uid: userID, name: name, profileImageURL: profileImageURL)
                        blockedUsers.append(userProfile)
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                if let error = fetchError {
                    completion(.failure(error))
                } else {
                    completion(.success(blockedUsers))
                }
                
              }
            
        }
        
    }
    //MARK: - 해당 유저 게시글 정보 필터링 해서 가져올 수 있는 함수
    func fetchUserPostsThumbnails(userID: String, completion: @escaping (Result<[ThumbnailPostResponse], Error>) -> Void) {
        let db = Firestore.firestore()
        
        // posts 컬렉션에서 특정 userID를 가진 문서만 가져옴(내 정보 가져올시 내 uid 사용)
        db.collection("posts")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { (querySnapshot, error) in
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
                       let thumbnailURL = data["thumbnail"] as? String,
                       let previewContent = data["previewContent"] as? String,
                       let likeCount = data["likeCount"] as? Int,
                       let commentCount = data["commentCount"] as? Int,
                       let createdAt = data["createdAt"] as? Timestamp {
                        
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
                
                completion(.success(thumbnails))
            }
    }
    //MARK: - 유저(본인) 프로필 불러오기
    func fetchUserProfile(uid: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { documentSnapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = documentSnapshot?.data(),
                  let uid = data["uid"] as? String,
                  let name = data["name"] as? String,
                  let profileImageURL = data["profileImageURL"] as? String,
                  let loginType = data["loginType"] as? String,
                  let lizardCount = data["lizardCount"] as? Int,
                  let postCount = data["postCount"] as? Int else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid user data"])))
                return
            }
            
            let userProfile = UserProfile(uid: uid, name: name, profileImageURL: profileImageURL, loginType: loginType, lizardCount: lizardCount, postCount: postCount)
            completion(.success(userProfile))
        }
    }
    //MARK: - 유저(본인) 작성했던 댓글 불러오기
    func fetchAllUserComments(userID: String, completion: @escaping (Result<[CommentResponse], Error>) -> Void) {
        let db = Firestore.firestore()
        
        db.collectionGroup("comments") // 모든 comments 서브컬렉션을 대상으로 쿼리
            .whereField("userID", isEqualTo: userID) // userID로 필터링
            .order(by: "createdAt", descending: true)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                var userComments: [CommentResponse] = []
                
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
                        userComments.append(comment)
                    }
                }
                
                completion(.success(userComments))
        }
        
    }
    
    
}

extension UserService {
    func updateUserProfile(uid: String, newName: String?, newProfileImage: UIImage?, completion: @escaping (Error?) -> Void) {
        // Firestore의 users 컬렉션에서 해당 유저 문서 참조
        let userRef = Firestore.firestore().collection("users").document(uid)
        
        // 새로운 닉네임이 제공되었는지 확인
        var updateData: [String: Any] = [:]
        if let newName = newName {
            updateData["name"] = newName
        }
        
        // 새로운 프로필 이미지가 있는지 확인
        if let newProfileImage = newProfileImage {
            // 기존 프로필 이미지 URL 가져오기
            userRef.getDocument { document, error in
                if let error = error {
                    completion(error)
                    return
                }
                
                guard let data = document?.data(),
                      let currentProfileImageURL = data["profileImageURL"] as? String else {
                    // 기존 프로필 이미지 URL을 가져오지 못한 경우
                    self.uploadNewProfileImage(uid: uid, newProfileImage: newProfileImage, userRef: userRef, updateData: updateData, completion: completion)
                    return
                }
                
                // Default 이미지인지 확인
                if !currentProfileImageURL.contains("default_profile.jpg") {
                    // 기존 이미지를 삭제
                    self.deleteImage(from: currentProfileImageURL) { error in
                        if let error = error {
                            completion(error)
                            return
                        }
                        // 새 이미지 업로드
                        self.uploadNewProfileImage(uid: uid, newProfileImage: newProfileImage, userRef: userRef, updateData: updateData, completion: completion)
                    }
                } else {
                    // Default 이미지는 삭제하지 않고 새 이미지만 업로드
                    self.uploadNewProfileImage(uid: uid, newProfileImage: newProfileImage, userRef: userRef, updateData: updateData, completion: completion)
                }
            }
        } else {
            // 프로필 이미지가 없으면 이름만 업데이트
            userRef.updateData(updateData) { error in
                completion(error)
            }
        }
    }
    
    // Storage 에 저장된 이미지 삭제 필요
    private func uploadNewProfileImage(uid: String, newProfileImage: UIImage, userRef: DocumentReference, updateData: [String: Any], completion: @escaping (Error?) -> Void) {
        guard let imageData = newProfileImage.jpegData(compressionQuality: 0.8) else {
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Image compression failed"]))
            return
        }
        
        let filePath = "profile_images/\(UUID().uuidString).jpg"
        let storageRef = Storage.storage().reference().child(filePath)
        
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                completion(error)
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(error)
                    return
                }
                
                if let downloadURL = url?.absoluteString {
                    var newData = updateData
                    newData["profileImageURL"] = downloadURL
                    userRef.updateData(newData) { error in
                        completion(error)
                    }
                }
            }
        }
    }
    
    
    private func extractFileName(from url: String) -> String? {
        guard let urlComponents = URLComponents(string: url),
              let path = urlComponents.path.removingPercentEncoding else {
            return nil
        }
        
        let pathComponents = path.split(separator: "/")
        return pathComponents.last?.components(separatedBy: "%2F").last
    }
    
    func deleteImage(from url: String, completion: @escaping (Error?) -> Void) {
        guard let fileName = extractFileName(from: url) else {
            print("Invalid file URL: \(url)")
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid file URL"]))
            return
        }
        
        // 기본 프로필 이미지는 삭제하지 않음
        if fileName != "default_profile.jpg" {
            let fileRef = Storage.storage().reference().child("profile_images/\(fileName)")
            print("Deleting file at path: \(fileRef.fullPath)")
            fileRef.delete { error in
                if let error = error {
                    print("Error deleting file at path: \(fileRef.fullPath) - \(error.localizedDescription)")
                } else {
                    print("Successfully deleted file at path: \(fileRef.fullPath)")
                }
                completion(error)
            }
        } else {
            completion(nil)
        }
    }
}
