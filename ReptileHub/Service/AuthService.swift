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


class AuthService: NSObject {
    static let shared = AuthService()
    private var currentNonce: String?
    private var loginCompletion: ((Bool) -> Void)?
    var currentAppleCredential: ASAuthorizationAppleIDCredential?
    private override init() {}

    // MARK: - Google OAuth 로그인
    func loginWithGoogle(presentingViewController: UIViewController, completion: @escaping (Bool) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(false)
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
            guard error == nil else {
                print("DEBUG: Google Sign-in 에러 발생 - \(error?.localizedDescription ?? "No Error Description")")
                completion(false)
                return
            }

            guard let user = result?.user else {
                print("DEBUG: Google Sign-in 에러 - 유저 찾기 실패")
                completion(false)
                return
            }

            let googleUser = GoogleAuthUser(user: user)

            self.checkIfUserExists(providerUID: googleUser.providerUID, loginType: googleUser.loginType) { exists in
                if exists {
                    self.signInToFirebase(user: googleUser, completion: completion)
                } else {
                    self.navigateToTermsAgreementView(user: googleUser, presentingViewController: presentingViewController, completion: completion)
                }
            }
        }
    }

    // MARK: - Apple OAuth 로그인
    func loginWithApple(presentingViewController: UIViewController, completion: @escaping (Bool) -> Void) {
        self.logout { success in
            guard success else {
                completion(false)
                return
            }

            let nonce = self.randomNonceString()
            self.currentNonce = nonce
            self.loginCompletion = completion

            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = self.sha256(nonce)

            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }
    }

    // MARK: - Kakao OAuth 로그인
    func loginWithKaKao(presentingViewController: UIViewController, completion: @escaping (Bool) -> Void) {
        if AuthApi.hasToken() {
            UserApi.shared.accessTokenInfo { accessTokenInfo, error in
                if let error = error {
                    print("DEBUG: Kakao 토큰 가져오기 에러 \(error.localizedDescription)")
                    self.requestKakaoOauth(presentingViewController: presentingViewController, completion: completion)
                } else {
                    self.requestKakaoOauth(presentingViewController: presentingViewController, completion: completion)
                }
            }
        } else {
            self.requestKakaoOauth(presentingViewController: presentingViewController, completion: completion)
        }
    }
    
    // MARK: - Firebase 관련 함수들
    private func checkIfUserExists(providerUID: String, loginType: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let userRef: Query

        if loginType == "Apple" {
            userRef = db.collection("users").whereField("appleUserID", isEqualTo: providerUID)
        } else {
            userRef = db.collection("users").whereField("providerUID", isEqualTo: providerUID)
        }

        userRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("DEBUG: Error checking user existence: \(error.localizedDescription)")
                completion(false)
            } else if let documents = querySnapshot?.documents, !documents.isEmpty {
                print("DEBUG: 유저가 존재합니다.")
                completion(true)
            } else {
                print("DEBUG: 유저가 존재하지 않습니다.")
                completion(false)
            }
        }
    }

    private func signInToFirebase(user: AuthUser, completion: @escaping (Bool) -> Void) {
        let credential: AuthCredential
        switch user.loginType {
        case "Google":
            guard let idToken = user.idToken, let accessToken = user.accessToken else {
                print("DEBUG: Google Auth Token is missing")
                completion(false)
                return
            }
            credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        case "Apple":
            guard let idToken = user.idToken else {
                print("DEBUG: Apple ID Token is missing")
                completion(false)
                return
            }
            credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idToken, rawNonce: currentNonce!)
        case "Kakao":
            let email = user.email ?? ""
            let password = user.uid
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    print("DEBUG: Firebase login failed: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("DEBUG: Firebase login success")
                    completion(true)
                }
            }
            return
        default:
            print("Unknown login type")
            completion(false)
            return
        }

        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                print("DEBUG: Firebase Sign In Error: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            completion(true)
        }
    }
    
    func logout(completion: @escaping (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            print("DEBUG: Firebase 로그아웃 성공")

            self.currentAppleCredential = nil

            ASAuthorizationAppleIDProvider().getCredentialState(forUserID: Auth.auth().currentUser?.uid ?? "") { (credentialState, error) in
                switch credentialState {
                case .revoked, .notFound:
                    print("DEBUG: Apple ID Credential Revoked or Not Found")
                    completion(true)
                case .authorized:
                    self.performAppleSignOut { signOutSuccess in
                        completion(signOutSuccess)
                    }
                default:
                    print("DEBUG: Unexpected Apple ID Credential State")
                    completion(true)
                }
            }
        } catch let signOutError as NSError {
            print("DEBUG: Firebase 로그아웃 에러: \(signOutError.localizedDescription)")
            completion(false)
        }
    }

    private func performAppleSignOut(completion: @escaping (Bool) -> Void) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: Auth.auth().currentUser?.uid ?? "") { (credentialState, error) in
            if let error = error {
                print("DEBUG: Apple Sign Out Error: \(error.localizedDescription)")
                completion(false)
                return
            }

            switch credentialState {
            case .revoked, .notFound:
                print("DEBUG: Apple ID Credential is Revoked or Not Found")
                completion(true)
            default:
                print("DEBUG: Unable to clear Apple ID Credential.")
                completion(false)
            }
        }
    }

    private func navigateToTermsAgreementView(user: AuthUser, presentingViewController: UIViewController, completion: @escaping (Bool) -> Void) {
        let termsVC = TermsAgreementViewController(user: user)
        termsVC.modalPresentationStyle = .fullScreen
        termsVC.onAgreementAccepted = {
            self.createFirebaseUser(user: user) { success in
                if success, let uid = Auth.auth().currentUser?.uid {
                    self.saveUserWithDefaultProfileImage(uid: uid, user: user) {
                        completion(true)
                    }
                } else {
                    completion(false)
                }
            }
        }
        
        termsVC.onAgreementDeclined = {
            completion(false)
        }
        
        presentingViewController.present(termsVC, animated: true, completion: nil)
    }
    
    private func createFirebaseUser(user: AuthUser, completion: @escaping (Bool) -> Void) {
        let credential: AuthCredential
        switch user.loginType {
        case "Google":
            guard let idToken = user.idToken, let accessToken = user.accessToken else {
                print("DEBUG: Google Auth Token is missing")
                completion(false)
                return
            }
            credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        case "Apple":
            guard let idToken = user.idToken else {
                print("DEBUG: Apple ID Token is missing")
                completion(false)
                return
            }
            credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idToken, rawNonce: currentNonce!)
        case "Kakao":
            let email = user.email ?? ""
            let password = user.uid
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    print("DEBUG: Firebase user creation failed: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("DEBUG: Firebase user creation success")
                    guard let uid = result?.user.uid else {
                        completion(false)
                        return
                    }
                    self.saveUserWithDefaultProfileImage(uid: uid, user: user) {
                        completion(true)
                    }
                }
            }
            return
        default:
            print("Unknown login type")
            completion(false)
            return
        }

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

            self.saveUserWithDefaultProfileImage(uid: uid, user: user) {
                completion(true)
            }
        }
    }
    
    private func saveUserWithDefaultProfileImage(uid: String, user: AuthUser, completion: @escaping () -> Void) {
        let defaultProfileImageRef = Storage.storage().reference().child("profile_images/default_profile.jpg")
        
        defaultProfileImageRef.downloadURL { url, error in
            if let error = error {
                print("DEBUG: Default Profile Image 에러 발생 - \(error.localizedDescription)")
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
    
    private func saveUserToFirestore(uid: String, user: AuthUser, profileImageURL: String, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        var userData: [String: Any] = [
            "uid": uid,
            "email": user.email ?? "",
            "name": user.name ?? "",
            "loginType": user.loginType,
            "providerUID": user.providerUID,
            "profileImageURL": profileImageURL
        ]
        
        if user.loginType == "Apple" {
            userData["appleUserID"] = user.uid
        }
        
        db.collection("users").document(uid).setData(userData) { error in
            if let error = error {
                print("Error saving user data: \(error.localizedDescription)")
            } else {
                print("유저 정보 저장 성공")
            }
            completion()
        }
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

// MARK: - 애플 로그인 관련 구현 함수들
extension AuthService: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let appleIDToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("DEBUG: Unable to fetch identity token")
                self.loginCompletion?(false)
                return
            }

            let rawNonce = self.currentNonce ?? ""
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: rawNonce)

            let appleUser = AppleAuthUser(credential: appleIDCredential)

            self.checkIfUserExists(providerUID: appleUser.uid, loginType: appleUser.loginType) { exists in
                if exists {
                    print("DEBUG: 유저가 존재합니다. Firebase 재인증을 시도합니다.")
                    if let currentUser = Auth.auth().currentUser {
                        print("DEBUG: 현재 Firebase 사용자: \(currentUser.uid)")

                        currentUser.reauthenticate(with: credential) { authResult, error in
                            if let error = error {
                                print("DEBUG: Reauthentication error: \(error.localizedDescription)")
                                self.loginCompletion?(false)
                            } else {
                                print("DEBUG: Reauthenticated with Apple ID successfully")
                                self.loginCompletion?(true)
                                // 재인증 성공 시 다음 화면으로 전환
                              //  self.navigateToMainScreen()
                            }
                        }
                    } else {
                        print("DEBUG: 현재 사용자가 없습니다. Firebase에 새로 로그인합니다.")
                        Auth.auth().signIn(with: credential) { authResult, error in
                            if let error = error {
                                print("DEBUG: Firebase Sign In Error: \(error.localizedDescription)")
                                self.loginCompletion?(false)
                            } else {
                                print("DEBUG: Firebase Sign In 성공")
                                self.loginCompletion?(true)
                               // self.navigateToMainScreen()
                            }
                        }
                    }
                } else {
                    if let presentingViewController = UIApplication.shared.windows.first?.rootViewController {
                        self.navigateToTermsAgreementView(user: appleUser, presentingViewController: presentingViewController, completion: self.loginCompletion ?? { _ in })
                    }
                }
            }
        } else {
            self.loginCompletion?(false)
        }
    }

    private func navigateToMainScreen() {
        DispatchQueue.main.async {
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
               let window = sceneDelegate.window {
                let mainVC = TabbarViewController() // 메인 화면으로 이동할 뷰 컨트롤러
                window.rootViewController = mainVC
                window.makeKeyAndVisible()
            }
        }
    }


    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first { $0.isKeyWindow } ?? UIWindow()
    }
}

// MARK: - 카카오 로그인 관련 구현 함수들
extension AuthService {
    private func requestKakaoOauth(presentingViewController: UIViewController, completion: @escaping (Bool) -> Void) {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                if let error = error {
                    print("DEBUG: KakaoTalk 로그인 실패 \(error.localizedDescription)")
                    completion(false)
                } else {
                    self.getKakaoUserInfo(presentingViewController: presentingViewController, completion: completion)
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                if let error = error {
                    print("DEBUG: Kakao 계정 로그인 실패 \(error.localizedDescription)")
                    completion(false)
                } else {
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
            
            self.checkIfUserExists(providerUID: kakaoUser.providerUID, loginType: kakaoUser.loginType) { exists in
                if exists {
                    self.signInToFirebase(user: kakaoUser, completion: completion)
                } else {
                    self.navigateToTermsAgreementView(user: kakaoUser, presentingViewController: presentingViewController, completion: completion)
                }
            }
        }
    }
}
