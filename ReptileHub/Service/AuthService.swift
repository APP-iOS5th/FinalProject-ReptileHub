//
//  AuthService.swift
//  ReptileHub
//
//  Created by 임재현 on 8/7/24.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import FirebaseStorage


class AuthService {
    static let shared = AuthService()
    private init() {}
    
    func loginWithGoogle(presentingViewController:UIViewController,completion: @escaping (Bool)-> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {return}
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
            guard error == nil else {
                print("DEBUG: 에러발생 - \(error?.localizedDescription ?? "No Error Description")")
                completion(false)
                return
            }
            
            guard let user = result?.user else {
                print ("DEBUG: Google Sign in 에러 - 유저 찾기 실패")
                completion(false)
                return
            }
            
            let idToken = user.idToken!.tokenString
            let accessToken = user.accessToken.tokenString
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            print("idToken \(idToken)")
            print("accessToken \(accessToken)")
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("DEBUG: Firebase Sign In Error: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                guard let uid = authResult?.user.uid else {
                    completion(false)
                    return
                }
                
                let db = Firestore.firestore()
                let docRef = db.collection("users").document(uid)
                
                docRef.getDocument { document, error in
                    if let documet = document, documet.exists {
                       // 사용자 데이터 존재하면 MainView로 이동
                        completion(true)
                    } else {
                        // 사용자 데이터가 없으면 약관동의View로 이동
                        self.navigateToTermsAgreementView(user:user,presentingViewController:presentingViewController,
                                                          completion:completion)
                    }
                }
            }
        }
    }
    
    private func navigateToTermsAgreementView(user:GIDGoogleUser,presentingViewController:UIViewController,completion:@escaping (Bool)->Void) {
        let termsVC = TermsAgreementViewController(user:user)
        termsVC.modalPresentationStyle = .fullScreen
        termsVC.onAgreementAccepted = {
            guard let uid = Auth.auth().currentUser?.uid else {
                completion(false)
                return
            }
            self.saveUserWithDefaultProfileImage(uid:uid,user:user) {
                completion(true)
            }
        }
        
        termsVC.onAgreementDeclined = {
            self.signOutAndDeleteUser()
            completion(false)
        }
        presentingViewController.present(termsVC, animated: false,completion: nil)
        
    }
    
    private func saveUserWithDefaultProfileImage(uid:String,user:GIDGoogleUser,completion: @escaping () -> Void) {
        let defaultProfileImageRef = Storage.storage().reference().child("profile_images/default_profile.jpg")
        
        defaultProfileImageRef.downloadURL { url, error in
            if let error = error {
                print("DEBUG: DefaultProfile Image 에러 발생 - \(error.localizedDescription)")
                completion()
                return
            }
            
            guard let downloadURL = url else {
                print("DEBUG: Default Profile image URL 없음")
                completion()
                return
            }
            self.saveUserToFirestore(uid: uid, user: user, profileImageURL: downloadURL.absoluteString, completion: completion)
            
        }
    }
    
    private func saveUserToFirestore(uid: String, user: GIDGoogleUser, profileImageURL:String,completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let userData: [String: Any] = [
            "uid": uid,
            "email": user.profile?.email ?? "",
            "name": user.profile?.name ?? "",
            "profileImageURL": profileImageURL
            //user.profile?.imageURL(withDimension: 100)?.absoluteString ?? ""
        ]
        
        db.collection("users").document(uid).setData(userData) { error in
            if let error = error {
                print("Error saving user data: \(error.localizedDescription)")
            } else {
                print("유저 정보 저장 성공 ")
                completion()
            }
        }
    }
    
    private func signOutAndDeleteUser() {
        guard let user = Auth.auth().currentUser else { return }
        user.delete { error in
            if let error = error {
                print("Error deleting user: \(error.localizedDescription)")
            } else {
                print("User deleted successfully")
            }
        }
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError.localizedDescription)")
        }
    }
    
    func addAuthStateDidChangeListener(completion: @escaping (User?) -> Void) {
        Auth.auth().addStateDidChangeListener { _ , user in
            completion(user)
        }
    }
    
    
}
