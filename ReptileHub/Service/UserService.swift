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
}
