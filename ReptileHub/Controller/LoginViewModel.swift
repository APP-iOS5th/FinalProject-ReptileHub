//
//  LoginViewModel.swift
//  ReptileHub
//
//  Created by 임재현 on 11/15/24.
//

import UIKit
import Combine

protocol AuthServiceProtocol {
    func loginWithKaKao(presentingViewController: UIViewController) -> AnyPublisher<KakaoAuthUser,Error>
    func loginWithGoogle(presentingViewController: UIViewController) -> AnyPublisher<Bool,Error>
    func loginWithApple(presentingViewController: UIViewController) -> AnyPublisher<Bool, Error>
}

final class LoginViewModel {
    private let authService: AuthServiceProtocol
    private var cancellable = Set<AnyCancellable>()
    
    enum LoginResult {
        case success
        case failure(LoginType, Error)
    }
    
    let loginStatusPublisher = PassthroughSubject<LoginResult, Never>()
    
    init(authService: AuthServiceProtocol, cancellable: Set<AnyCancellable> = Set<AnyCancellable>()) {
        self.authService = authService
        self.cancellable = cancellable
        print("LoginViewModelInIt()")
    }
    
    func handleLogin(with type: LoginType, from viewController: UIViewController) {
        print("ViewModel:\(type) 로그인 처리 시작")
        
        switch type {
        case .kakao:
            authService.loginWithKaKao(presentingViewController: viewController)
                .sink { [weak self] completion in
                    if case .failure(let error) = completion {
                        print("VideModel: 카카오 로그인 실패\(error.localizedDescription)")
                        self?.loginStatusPublisher.send(.failure(.kakao, error))
                    }
                } receiveValue: { [weak self] success in
                    print("VideModel: 카카오 로그인 성공")
                    self?.loginStatusPublisher.send(.success)
                }
                .store(in: &cancellable)
        case .google:
            authService.loginWithGoogle(presentingViewController: viewController)
                .sink { [weak self] completion in
                    if case .failure(let error) = completion {
                        print("VideModel: 구글 로그인 실패\(error.localizedDescription)")
                        self?.loginStatusPublisher.send(.failure(.google, error))
                    }
                } receiveValue: { [weak self] success in
                    print("VideModel: 카카오 로그인 성공")
                    self?.loginStatusPublisher.send(.success)
                }
                .store(in: &cancellable)

        case .apple:
            authService.loginWithApple(presentingViewController: viewController)
                .sink { [weak self] completion in
                    if case .failure(let error) = completion {
                        print("VideModel: 애플 로그인 실패\(error.localizedDescription)")
                        self?.loginStatusPublisher.send(.failure(.apple, error))
                    }
                } receiveValue: { [weak self] success in
                    print("VideModel: 카카오 로그인 성공")
                    self?.loginStatusPublisher.send(.success)
                }
                .store(in: &cancellable)

        }
        
        
        
        
    }
}
