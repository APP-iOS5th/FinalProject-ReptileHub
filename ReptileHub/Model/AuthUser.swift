//
//  AuthUser.swift
//  ReptileHub
//
//  Created by 임재현 on 8/8/24.
//

import GoogleSignIn
import AuthenticationServices
import KakaoSDKUser


protocol AuthUser {
    var uid: String { get }
    var email: String? { get }
    var name: String? { get }
    var loginType: String { get }
    var idToken: String? { get }
    var accessToken: String? { get }
    var providerUID: String { get }
}

// GoogleAuthUser 클래스 정의
struct GoogleAuthUser: AuthUser {
    let loginType: String
    let uid: String
    let email: String?
    let name: String?
    let idToken: String?
    let accessToken: String?
    let providerUID: String

    init(user: GIDGoogleUser) {
        self.uid = user.userID ?? ""
        self.email = user.profile?.email
        self.name = user.profile?.name
        self.idToken = user.idToken?.tokenString
        self.accessToken = user.accessToken.tokenString
        self.providerUID = user.userID ?? ""
        self.loginType = "Google"
    }
}

// AppleAuthUser 클래스 정의
struct AppleAuthUser: AuthUser {
    let loginType: String
    let uid: String
    let email: String?
    let name: String?
    let idToken: String? //
    let accessToken: String? = nil
    let providerUID: String

    init(credential: ASAuthorizationAppleIDCredential) {
        self.uid = credential.user
        self.email = credential.email
        self.name = credential.fullName?.formatted()
        self.idToken = String(data: credential.identityToken ?? Data(), encoding: .utf8)
        self.providerUID = credential.user // Apple 고유 사용자 ID
        self.loginType = "Apple"
    }
}

// KakaoAuthUser 클래스 정의
struct KakaoAuthUser: AuthUser {
    let loginType: String
    let uid: String
    let email: String?
    let name: String?
    let idToken: String? = nil // Kakao는 ID 토큰이 없음
    let accessToken: String? = nil // Access 토큰
    let providerUID: String // Kakao 고유 사용자 ID
    
    init(user:KakaoSDKUser.User) {
        self.uid = String(describing: user.id)
        self.email = user.kakaoAccount?.email
        self.name = user.kakaoAccount?.profile?.nickname
        self.providerUID = String(describing: user.id)
        self.loginType = "Kakao"
    }
}
