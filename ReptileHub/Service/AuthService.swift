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
    func loginWithGoogle(presentingViewController: UIViewController, completion: @escaping (Bool) -> Void) {
        print("구글 로그인 시작")
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("구글 로그인 클라이언트 아이디 없음")
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
                print("DEBUG: Google Sign in 에러 - 유저 찾기 실패")
                completion(false)
                return
            }

            // idToken과 accessToken은 이제 옵셔널이 아니기 때문에 직접 접근 가능
            guard let idToken = user.idToken?.tokenString else { return }
            let accessToken = user.accessToken.tokenString

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

            // Firebase에 로그인
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("DEBUG: Firebase Sign In Error: \(error.localizedDescription)")
                    completion(false)
                    return
                }

                guard let authUser = authResult?.user else {
                    print("DEBUG: Firebase 사용자 없음")
                    completion(false)
                    return
                }

                print("Firebase 로그인 성공: \(authUser.uid)")

                // Firestore에서 유저 존재 여부 확인
                self.checkIfUserExists(providerUID: user.userID ?? "", loginType: "Google") { exists in
                    if exists {
                        print("이미 유저가 존재하는 경우 바로 로그인 처리, 현재 구글 유저 uid : \(user.userID ?? "")")
                        completion(true)
                    } else {
                        print("유저가 존재하지 않는 경우 약관 동의 뷰로 이동")
                        let googleUser = GoogleAuthUser(user: user)
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
    private func checkIfUserExists(providerUID: String, loginType: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").whereField("providerUID", isEqualTo: providerUID)
        
        userRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("DEBUG: Error checking user existence: \(error.localizedDescription)")
                completion(false)
            } else if querySnapshot?.isEmpty == false {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    
    // FirebaseAuth에 사용자 등록
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
                    Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                        if let error = error {
                            print("DEBUG: Firebase login failed: \(error.localizedDescription)")
                            completion(false)
                        } else {
                            print("DEBUG: Firebase login success")
                            guard let uid = authResult?.user.uid else {
                                completion(false)
                                return
                            }
                            self.saveUserWithDefaultProfileImage(uid: uid, user: user) {
                                completion(true)
                            }
                        }
                    }
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
        
        // Firebase에 로그인
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
            
            // 기본 프로필 이미지 부여 후 Firestore에 사용자 정보 저장
            self.saveUserWithDefaultProfileImage(uid: uid, user: user) {
                completion(true)
            }
        }
    }
    
    private func saveUserToFirestore(uid: String, user: AuthUser, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let userData: [String: Any] = [
            "uid": uid,
            "email": user.email ?? "",
            "name": user.name ?? "",
            "loginType": user.loginType,
            "providerUID": user.providerUID
        ]
        
        db.collection("users").document(uid).setData(userData) { error in
            if let error = error {
                print("Error saving user data: \(error.localizedDescription)")
                completion()
            } else {
                print("유저 정보 저장 성공 ")
                completion()
            }
        }
    }
    
    // 약관 동의 VIEW로 이동하는 함수
    private func navigateToTermsAgreementView(user: AuthUser, presentingViewController: UIViewController, completion: @escaping (Bool) -> Void) {
        let termsVC = TermsAgreementViewController(user: user)
        termsVC.modalPresentationStyle = .fullScreen
        termsVC.onAgreementAccepted = {
            // 회원가입 진행 시 사용자의 Firebase Auth 등록
            self.createFirebaseUser(user: user) { success in
                if success, let uid = Auth.auth().currentUser?.uid {
                    // 기본 프로필 이미지 부여 후 Firestore에 사용자 정보 저장
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
    
    // 기타 필요한 함수들
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
            
            let appleUser = AppleAuthUser(credential: appleIDCredential)
            
            // 소셜 로그인 성공 후 Firestore에서 유저 존재 여부 확인
            self.checkIfUserExists(providerUID: appleUser.uid, loginType: appleUser.loginType) { exists in
                if exists {
                    // 유저가 존재하면 로그인 처리
                    self.loginCompletion?(true)
                } else {
                    // 유저가 존재하지 않으면 약관 동의 뷰로 이동
                    self.navigateToTermsAgreementView(user: appleUser, presentingViewController: presentingViewController, completion: self.loginCompletion ?? { _ in })
                }
            }
        } else {
            self.loginCompletion?(false)
        }
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first { $0.isKeyWindow } ?? UIWindow()
    }
}

//MARK: - 카카오 로그인 관련 구현 함수들
extension AuthService {
    // 카카오 로그인 요청
    private func requestKakaoOauth(presentingViewController: UIViewController, completion: @escaping (Bool) -> Void) {
        // 카카오톡이 있을 경우
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
            
            // 소셜 로그인 성공 후 Firestore에서 유저 존재 여부 확인
            self.checkIfUserExists(providerUID: kakaoUser.uid, loginType: kakaoUser.loginType) { exists in
                if exists {
                    // 유저가 존재하면 바로 로그인 처리
                    completion(true)
                } else {
                    // 유저가 존재하지 않으면 약관 동의 뷰로 이동
                    self.navigateToTermsAgreementView(user: kakaoUser, presentingViewController: presentingViewController, completion: completion)
                }
            }
        }
    }
    
    
    
    // 기본 프로필 이미지 부여 및 Firestore에 사용자 정보 저장
    private func saveUserWithDefaultProfileImage(uid: String, user: AuthUser, completion: @escaping () -> Void) {
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
            
            // Firestore에 사용자 정보를 저장
            self.saveUserToFirestore(uid: uid, user: user, profileImageURL: downloadURL.absoluteString, completion: completion)
        }
    }
    
    // Firestore에 사용자 정보를 저장하는 함수
    private func saveUserToFirestore(uid: String, user: AuthUser, profileImageURL: String, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let userData: [String: Any] = [
            "uid": uid,
            "email": user.email ?? "",
            "name": user.name ?? "",
            "loginType": user.loginType,
            "providerUID": user.providerUID,
            "profileImageURL": profileImageURL // 기본 프로필 이미지 URL 추가
        ]
        
        db.collection("users").document(uid).setData(userData) { error in
            if let error = error {
                print("Error saving user data: \(error.localizedDescription)")
            } else {
                print("유저 정보 저장 성공")
            }
            completion()
        }
    }
    
}
