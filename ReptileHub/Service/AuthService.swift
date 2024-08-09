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
import AuthenticationServices
import CryptoKit
import KakaoSDKAuth
import KakaoSDKUser




class AuthService:NSObject {
    static let shared = AuthService()
    private var currentNonce: String?
    private var loginCompletion: ((Bool) -> Void)?
    private override init() {}
    
    //MARK: - Google OAuth 로그인
    func loginWithGoogle(presentingViewController:UIViewController,completion: @escaping (Bool)-> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(false)
            return
        }
        
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
                
                let googleUser = GoogleAuthUser(user: user)
                self.checkIfUserExists(uid: uid, email: googleUser.email, name: googleUser.name) { exists in
                    if exists {
                        completion(true)
                    } else {
                        self.navigateToTermsAgreementView(user: googleUser, presentingViewController: presentingViewController, completion: completion)
                    }
                }
                
            }
        }
    }
    
    //MARK: - APPLE OAUTH 로그인
    func loginWithApple(presentingViewController: UIViewController, completion: @escaping (Bool) -> Void) {
        let nonce = randomNonceString()
        currentNonce = nonce
        self.loginCompletion = completion
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    //MARK: - KaKao OAUTH 로그인
    func loginWithKaKao(presentingViewController: UIViewController, completion: @escaping (Bool) -> Void) {
        if AuthApi.hasToken() {
            print("Token exists, checking validity...")
            UserApi.shared.accessTokenInfo { accessTokenInfo, error in
                if let error = error {
                    print("DEBUG: 카카오톡 토큰 가져오기 에러 \(error.localizedDescription)")
                    self.requestKakaoOauth(presentingViewController: presentingViewController, completion: completion)
                    print("Token error, requesting OAuth")
                } else {
                    // 토큰이 유효한 경우 사용자 정보 가져오기
                    print("Token is valid, retrieving user info")
                    self.requestKakaoOauth(presentingViewController: presentingViewController, completion: completion)
                    
                }
            }
        } else {
            print("No token, requesting OAuth")
            self.requestKakaoOauth(presentingViewController: presentingViewController, completion: completion)
        }
    }
    
}

//MARK: - FIREBASE 관련 함수들
extension AuthService {
    // 유저가 회원가입이 되어있는지 검증하는 함수
    private func checkIfUserExists(uid: String, email: String?, name: String?, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(uid)
        
        docRef.getDocument { document, error in
            if let document = document, document.exists {
                completion(true)
            } else {
                let defaultProfileImageRef = Storage.storage().reference().child("profile_images/default_profile.jpg")
                defaultProfileImageRef.downloadURL { url, error in
                    if let error = error {
                        print("DEBUG: DefaultProfile Image 에러 발생 - \(error.localizedDescription)")
                        completion(false)
                        return
                    }
                    guard let downloadURL = url else {
                        print("DEBUG: Default Profile image URL 없음")
                        completion(false)
                        return
                    }
                    
                    let userData: [String: Any] = [
                        "uid": uid,
                        "email": email ?? "",
                        "name": name ?? "",
                        "profileImageURL": downloadURL.absoluteString
                    ]
                    db.collection("users").document(uid).setData(userData) { error in
                        if let error = error {
                            print("DEBUG: 유저 데이터 저장 실패 - \(error.localizedDescription)")
                        } else {
                            print("유저 정보 저장 성공")
                        }
                        completion(false)
                    }
                }
            }
        }
    }
    
    // 처음 회원가입 시 약관동의 VIEW 로 이동하는 함수
    private func navigateToTermsAgreementView(user:AuthUser,presentingViewController:UIViewController,completion:@escaping (Bool)->Void) {
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
            
            guard let uid = Auth.auth().currentUser?.uid else {
                           completion(false)
                           return
                       }
            print("userUID - \(uid)")
            
            self.deleteUserFromFirestore(uid: uid) { success in
                if success {
                    self.signOutAndDeleteUser {
                        completion(false)
                    }
                } else {
                    completion(false)
                }
            }
        }
        presentingViewController.present(termsVC, animated: false,completion: nil)
        
    }
    //회원가입시 유저에게 기본 프로필 이미지 부여하는 함수
    private func saveUserWithDefaultProfileImage(uid:String,user:AuthUser,completion: @escaping () -> Void) {
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
    // 부여되는 기본 프로필과 함께 유저 정보 FireStore에 저장하는 함수 - 문서는 유저 고유 UID 로 저장되어 검색 가능
    private func saveUserToFirestore(uid: String, user: AuthUser, profileImageURL:String,completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let userData: [String: Any] = [
            "uid": uid,
            "email": user.email ?? "",
            "name": user.name ?? "",
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
    // 회원가입 진행 중 유저가 취소했을경우 해당 유저 정보 FireStore에서 삭제하는 함수
    private func deleteUserFromFirestore(uid: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).delete { error in
            if let error = error {
                print("Error deleting user data: \(error.localizedDescription)")
                completion(false)
            } else {
                print("User data deleted successfully")
                completion(true)
            }
        }
    }
    
    // 회원가입 진행 중 유저가 취소했을경우 해당 유저 Authentication 에서 삭제 및 로그아웃
    private func signOutAndDeleteUser(completion: @escaping () -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion()
            return
        }
        user.delete { error in
            if let error = error {
                print("Error deleting user: \(error.localizedDescription)")
            } else {
                print("User deleted successfully")
            }
            completion()
        }
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError.localizedDescription)")
        }
    }
    
    // 유저 상태 감지 함수?
    func addAuthStateDidChangeListener(completion: @escaping (FirebaseAuth.User?) -> Void) {
        Auth.auth().addStateDidChangeListener { _ , user in
            completion(user)
        }
    }
}


//MARK: -  애플 로그인 관련 구현 함수들
extension AuthService: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    // Apple Sign In 응답 처리
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let presentingViewController = UIApplication.shared.windows.first?.rootViewController else {
            loginCompletion?(false)
            return
        }
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("DEBUG: Unable to fetch identity token")
                loginCompletion?(false)
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("DEBUG: Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                loginCompletion?(false)
                return
            }
            let credential = OAuthProvider.credential(providerID:.apple , idToken: idTokenString, rawNonce: nonce)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("DEBUG: Error authenticating: \(error.localizedDescription)")
                    self.loginCompletion?(false)
                    return
                }
                
                guard let uid = authResult?.user.uid else {
                    self.loginCompletion?(false)
                    return
                }
                
                let appleUser = AppleAuthUser(credential: appleIDCredential)
            
                self.checkIfUserExists(uid: uid, email: appleUser.email, name: appleUser.name) { exists in
                    if exists {
                        self.loginCompletion?(true)
                    } else {
                        self.navigateToTermsAgreementView(user: appleUser, presentingViewController: presentingViewController, completion: self.loginCompletion ?? { _ in })
                    }
                }
            }
        } else {
            self.loginCompletion?(false)
        }
    }
    
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first { $0.isKeyWindow } ?? UIWindow()
    }
   
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap { String(format: "%02x", $0) }.joined()

        return hashString
    }
    
}

//MARK: -  카카오 로그인 관련 구현 함수들
extension AuthService {
    // 카카오 로그인 요청
    private func requestKakaoOauth(presentingViewController: UIViewController, completion: @escaping (Bool) -> Void) {
        // 카카오톡이 있을경우
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                if let error = error {
                    print("DEBUG: 카카오톡 로그인 실패 \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("loginWithKakaoTalk() success.")
                    self.getKakaoUserInfo(presentingViewController: presentingViewController, completion: completion)
                }
            }
        } else {
            // 카카오톡이 없을 경우
            UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                if let error = error {
                    print("DEBUG: 카카오 계정 로그인 실패 \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("loginWithKakaoAccount() success.")
                    self.getKakaoUserInfo(presentingViewController: presentingViewController, completion: completion)
                }
            }
        }
    }

    
    private func getKakaoUserInfo(presentingViewController: UIViewController, completion: @escaping (Bool) -> Void) {
        UserApi.shared.me { user, error in
            if let error = error {
                DispatchQueue.main.async {
                    print("DEBUG: 사용자 정보 요청 에러 \(error.localizedDescription)")
                    completion(false)
                }
                return
            }
            
            guard let user = user else {
                DispatchQueue.main.async {
                    print("DEBUG: 사용자 정보가 없습니다.")
                    completion(false)
                }
                return
            }
            
            let kakaoUser = KakaoAuthUser(user: user)
            let password = String(describing: user.id)
            print("kakaoUser = \(kakaoUser),- \(password)")
            
            // 파이어베이스에 사용자 생성 시도
            Auth.auth().createUser(withEmail:kakaoUser.email!, password: password) { result, error in
                if let error = error {
                    print("DEBUG: 파이어베이스 사용자 생성 실패 \(error.localizedDescription)")
                    
                    // 사용자 생성이 실패하면, 로그인 시도
                    Auth.auth().signIn(withEmail: kakaoUser.email!, password: password) { authResult, error in
                        if let error = error {
                            print("DEBUG: 파이어베이스 로그인 실패 \(error.localizedDescription)")
                            completion(false)
                        } else {
                            print("DEBUG: 파이어베이스 로그인 성공")
                            
                            // 유저가 이미 존재하는 경우, Firestore에서 확인 및 저장 로직
                            guard let uid = authResult?.user.uid else {
                                completion(false)
                                return
                            }
                            
                            self.checkIfUserExists(uid: uid, email: kakaoUser.email, name: kakaoUser.name) { exists in
                                if exists {
                                    completion(true)
                                } else {
                                    // 유저 정보가 Firestore에 없으면 이는 비정상적인 상태이므로 에러 발생
                                    print("DEBUG: Firestore에 유저 정보가 없습니다. 비정상적인 상태.")
                                    completion(false)
                                }
                            }
                        }
                    }
                    
                } else {
                    print("DEBUG: 파이어베이스 사용자 생성 성공")
                    
                    // 새로 사용자 생성에 성공한 경우, 약관 동의 뷰로 이동
                    guard let uid = result?.user.uid else {
                        completion(false)
                        return
                    }
                    
                    self.navigateToTermsAgreementView(user: kakaoUser, presentingViewController: presentingViewController) { success in
                        if success {
                            // 약관 동의 완료 후 유저 정보 저장
                            self.saveUserWithDefaultProfileImage(uid: uid, user: kakaoUser) {
                                completion(true)
                            }
                        } else {
                            completion(false)
                        }
                    }
                }
            }
        }
    }

}
