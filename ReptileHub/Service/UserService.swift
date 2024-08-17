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
    func fetchBlockUsers(currentUserID: String, completion: @escaping(Result<[UserProfile],Error>)->Void) {
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
            var blockedUsers: [UserProfile] = []
            var fetchError:Error?
            
            for userID in blockedUserIDs {
                group.enter()
                
                db.collection("users").document(userID).getDocument { userDocument, error in
                    if let error = error {
                        fetchError = error
                    } else if let userData = userDocument?.data(),
                              let name = userData["name"] as? String,
                              let profileImageURL = userData["profileImageURL"] as? String {
                        let userProfile = UserProfile(uid: userID, name: name, profileImageURL: profileImageURL)
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
    
    
}
