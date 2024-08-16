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
    
}
