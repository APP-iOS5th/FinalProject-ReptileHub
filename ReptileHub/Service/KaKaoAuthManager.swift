//
//  KaKaoAuthManager.swift
//  ReptileHub
//
//  Created by 임재현 on 11/20/24.
//

import KakaoSDKAuth
import KakaoSDKUser
import Combine
import UIKit

protocol KaKaoAuthManagerProtocol {
    func login(presentingViewController: UIViewController) -> AnyPublisher<KakaoAuthUser,Error>
}

final class KaKaoAuthManager: KaKaoAuthManagerProtocol {
    private var cancellables = Set<AnyCancellable>()
    
    func login(presentingViewController: UIViewController) -> AnyPublisher<KakaoAuthUser, Error> {
        let loginPublisher = UserApi.isKakaoTalkLoginAvailable() ? loginWithKaKaoTalk() : loginWithKakaoAccount()
        
        return loginPublisher
            .flatMap { success -> AnyPublisher<KakaoAuthUser,Error> in
                guard success else {
                    return Fail(error: NSError(domain: "KaKaoAuth",
                                               code: -1,
                                               userInfo: [NSLocalizedDescriptionKey:"Login failed"]))
                    .eraseToAnyPublisher()
                    
                }
                
                return self.getKaKaoUserInfo()
            }
            .eraseToAnyPublisher()
 
    }
    
    
    private func loginWithKaKaoTalk() -> AnyPublisher<Bool,Error> {
        return Future<Bool,Error> { promise in
            UserApi.shared.loginWithKakaoTalk { _, error in
                if let error = error {
                    print("카카오톡 로그인 실패: \(error.localizedDescription)")
                    promise(.failure(error))
                } else {
                    print("카카오톡 로그인 성공")
                    promise(.success(true))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func loginWithKakaoAccount() -> AnyPublisher<Bool,Error> {
        return Future<Bool,Error> { promise in
            UserApi.shared.loginWithKakaoAccount { _, error in
                if let error = error {
                    print("카카오 웹 로그인 실패: \(error.localizedDescription)")
                    promise(.failure(error))
                } else {
                    print("카카오 웹 로그인 성공")
                    promise(.success(true))
                }
            }
            
        }
        .eraseToAnyPublisher()
    }

    
    private func getKaKaoUserInfo() -> AnyPublisher<KakaoAuthUser,Error> {
         Future<KakaoAuthUser,Error> { promise in
             UserApi.shared.me { user, error in
                 if let error = error {
                     print("사용자 요청 실패 : \(error.localizedDescription)")
                     return
                 }
                 
                 guard let user = user else {
                     let error = NSError(domain: "KaKaoAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자 정보가 없습니다"])
                     promise(.failure(error))
                     return
                 }
                 
                 let kakaoUser = KakaoAuthUser(user: user)
                 promise(.success(kakaoUser))
             }
            
        }
         .eraseToAnyPublisher()
    }
}
