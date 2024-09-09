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
            credential = OAuthProvider.credential(providerID: .apple, idToken: idToken, rawNonce: currentNonce!)
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
        DispatchQueue.main.async {
            let termsVC = TermsAgreementViewController(user: user) // authorizationCode 전달
            termsVC.modalPresentationStyle = .fullScreen
            termsVC.onAgreementAccepted = {
                self.createFirebaseUser(user: user) { success in
                    if success, let uid = Auth.auth().currentUser?.uid {
                        self.saveUserWithDefaultProfileImage(uid: uid, user: user) {
                            // 약관 동의 후, refreshToken 생성 로직 추가
                            if user.loginType == "Apple", let code = termsVC.authorizationCode {
                                // 비동기 작업이 완료된 후에도 UI 업데이트는 메인 스레드에서 실행
                                DispatchQueue.main.async {
                                    self.getAppleRefreshToken(code: code) { result in
                                        switch result {
                                        case .success(let refreshToken):
                                            UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
                                            UserDefaults.standard.synchronize()
                                            print("DEBUG: Refresh token saved successfully.")
                                        case .failure(let error):
                                            print("DEBUG: Failed to get refresh token - \(error.localizedDescription)")
                                        }
                                        completion(true)
                                    }
                                }
                            } else {
                                completion(true)
                            }
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
            credential = OAuthProvider.credential(providerID: .apple, idToken: idToken, rawNonce: currentNonce!)
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
        let randomNickname = generateRandomNickname()
        var userData: [String: Any] = [
            "uid": uid,
            "email": user.email ?? "",
            "name": randomNickname,
            "loginType": user.loginType,
            "providerUID": user.providerUID,
            "profileImageURL": profileImageURL,
            "isVaildUser": true
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
    //MARK: - 유저 회원가입 시 랜덤 닉네임 부여
    private func generateRandomNickname() -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        let randomCharacters = (0..<8).map { _ in characters.randomElement()! }
        return "User-\(String(randomCharacters))" // User- 접두사와 랜덤 문자 결합
    }
    
    //MARK: - 애플 로그인 랜덤 난수 만들기
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

            let credential = OAuthProvider.credential(providerID: .apple, idToken: idTokenString, rawNonce: rawNonce)


            // AppleAuthUser 객체를 생성할 때 authorizationCode 포함
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
                                // self.navigateToMainScreen()
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
                        // authorizationCode는 appleUser 객체를 통해 전달됨
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
   //MARK: - 회원가입 당시 애플 리프레쉬 토큰 만드는 함수
    private func getAppleRefreshToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        print("리프레쉬토큰 생성중 ....")
        let urlString = "https://us-central1-testforfinal-e5ce4.cloudfunctions.net/getRefreshToken?code=\(code)"
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("DEBUG: Error in getting refresh token - \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let data = data, let refreshToken = String(data: data, encoding: .utf8) else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse refresh token"])))
                    return
                }
                
                print("DEBUG: Successfully fetched refresh token - \(refreshToken)")
                completion(.success(refreshToken))
            }
        }
        
        task.resume()
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

extension AuthService {
 
    func deleteUserAccount(userID: String, loginType: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)

        
        // 기본값 설정
        let defaultProfileImageURL = "https://firebasestorage.googleapis.com/v0/b/reptilehub-a8815.appspot.com/o/profile_images%2FinVaild_Profile.jpeg?alt=media&token=4379f3e7-2c2e-4d51-a06b-f095d15f7ee1" // 기본 이미지 URL
        let defaultName = "탈퇴한 유저"
        let defaultInfo = "알수없음"

        // DispatchGroup을 사용해 모든 비동기 작업이 완료될 때까지 기다림
        let group = DispatchGroup()

        // Apple 로그인 유저의 경우 refreshToken을 해제하기 위한 로직
        if loginType == "Apple", let refreshToken = UserDefaults.standard.string(forKey: "refreshToken") {
            group.enter()
            //Todo - UR
            let urlString = "https://us-central1-reptilehub-a8815.cloudfunctions.net/revokeToken?refresh_token=\(refreshToken)"
            if let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let url = URL(string: encodedURL) {
                let task = URLSession.shared.dataTask(with: url) { data, response, error in
                    if let error = error {
                        print("Error revoking Apple refresh token: \(error.localizedDescription)")
                    } else {
                        print("Successfully revoked Apple refresh token.")
                    }
                    group.leave()
                }
                task.resume()
            } else {
                group.leave()
            }
        }

        // 유저 프로필 정보 업데이트
        group.enter()
        userRef.updateData([
            "name": defaultName,
            "profileImageURL": defaultProfileImageURL,
            "providerUID": defaultInfo,
            "loginType": defaultInfo,
            "lizardCount": 0,
            "postCount": 0,
            "isVaildUser": false
        ]) { error in
            if let error = error {
                completion(error)
                group.leave()
                return
            }

            // 프로필 이미지가 기본 이미지가 아니라면 삭제
            userRef.getDocument { (document, error) in
                if let document = document, document.exists, let data = document.data() {
                    if let currentProfileImageURL = data["profileImageURL"] as? String, currentProfileImageURL != defaultProfileImageURL {
                        self.deleteImage(from: currentProfileImageURL) { error in
                            if let error = error {
                                print("프로필 이미지 삭제 에러: \(error.localizedDescription)")
                            } else {
                                print("프로필 이미지가 성공적으로 삭제되었습니다.")
                            }
                        }
                    }
                }
                group.leave()
            }
        }

        // 모든 성장일지 삭제
        group.enter()
        DiaryPostService.shared.deleteAllGrowthDiaries(forUser: userID) { error in
            if let error = error {
                completion(error)
                group.leave()
                return
            }
            group.leave()
        }

        // 모든 작업이 완료되면 FirebaseAuth에서 유저 삭제 후 로그아웃
        group.notify(queue: .main) {
            if let user = Auth.auth().currentUser {
                user.delete { error in
                    if let error = error {
                        print("FirebaseAuth에서 유저 삭제 에러: \(error.localizedDescription)")
                        completion(error)
                    } else {
                        print("FirebaseAuth에서 유저가 성공적으로 삭제되었습니다.")
                        // 탈퇴 후 로그인 화면으로 이동하는 로직 추가
                        self.navigateToLoginScreen()
                        completion(nil)
                    }
                }
            } else {
                print("현재 로그인된 유저가 없습니다.")
                self.navigateToLoginScreen()
                completion(nil)
            }
        }
        
        // FirebaseAuth 로그아웃 처리
        do {
            try Auth.auth().signOut()
            print("FirebaseAuth 로그아웃 성공")
        } catch let signOutError as NSError {
            print("FirebaseAuth 로그아웃 에러: \(signOutError.localizedDescription)")
        }
    }

    private func navigateToLoginScreen() {
        DispatchQueue.main.async {
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
               let window = sceneDelegate.window {
                let loginVC = LoginViewController() // 로그인 화면으로 이동할 뷰 컨트롤러
                window.rootViewController = loginVC
                window.makeKeyAndVisible()
            }
        }
    }
}

extension AuthService {
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
