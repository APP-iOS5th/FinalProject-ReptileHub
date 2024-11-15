//
//  LoginViewController.swift
//  ReptileHub
//
//  Created by 임재현 on 8/7/24.
//

import UIKit
import FirebaseAuth
import SnapKit
import Combine

class LoginViewController: UIViewController {
    private let viewModel: LoginViewModel
    private let loginView = LoginView()
    private var cancellable = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupActions()
        bindViewModel()
        
        if let user = Auth.auth().currentUser {
            // 로그인 화면에서 이 문구가 디버깅 되면 로그아웃이 제대로 되지 않았음을 의미
            print("currentUser \(user.uid)")
        }
        print("LogiinViewController viewDidLoad init()")
        
   
    }    
    
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        print("LoginVC init()")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear")
//        loginView.kakaoButton.removeTarget(self, action: #selector(handleLogin(_:)), for: .touchUpInside)
//        loginView.googleButton.removeTarget(self, action: #selector(handleLogin(_:)), for: .touchUpInside)
//        loginView.appleButton.removeTarget(self, action: #selector(handleLogin(_:)), for: .touchUpInside)
    }
    
    private func bindViewModel() {
        loginView.loginButtonTapPublisher
            .sink { [weak self] loginType in
                print("ViewController: 로그인 타입\(loginType) 전달")
                guard let self = self else { return }
                self.viewModel.handleLogin(with: loginType, from: self)
            }
            .store(in: &cancellable)
    }
    
    
    
    private func setupView() {
        view.addSubview(loginView)
        loginView.snp.makeConstraints {
        $0.edges.equalToSuperview()
        }
    }
    
    private func setupActions() {
//        loginView.kakaoButton.addTarget(self, action: #selector(handleLogin(_:)), for: .touchUpInside)
//        loginView.googleButton.addTarget(self, action: #selector(handleLogin(_:)), for: .touchUpInside)
//        loginView.appleButton.addTarget(self, action: #selector(handleLogin(_:)), for: .touchUpInside)
    }
    
    @objc func handleLogin(_ sender: UIButton) {
//        if sender == loginView.kakaoButton {
//            print("KaKao Login")
//            kakaoLoginButtonTapped()
//        } else if sender == loginView.googleButton {
//            print("Google Login")
//            googleLoginButtonTapped()
//        } else if sender == loginView.appleButton {
//            print("Apple Login")
//            appleLoginButtonTapped()
//        }
    }
    
    private func googleLoginButtonTapped() {
//        print("google 버튼")
//        AuthService.shared.loginWithGoogle(presentingViewController: self) { success in
//            if success {
//                self.navigateToMainView()
//                print("로그인 성공")
//            } else {
//                let loginType = "Google"
//                self.showLoginError(loginType:loginType)
//                print("로그인 실패 : \(self.showLoginError(loginType: loginType))")
//            }
//        }
    }
    
    private func appleLoginButtonTapped() {
//        print("apple 버튼")
//        AuthService.shared.loginWithApple(presentingViewController: self) { success in
//            if success {
//                self.navigateToMainView()
//            } else {
//                let loginType = "Apple"
//                self.showLoginError(loginType:loginType)
//            }
//        }
    }
    
    private func kakaoLoginButtonTapped() {
//        print("kakao 버튼")
//        AuthService.shared.loginWithKaKao(presentingViewController: self) { success in
//            if success {
//                self.navigateToMainView()
//            } else {
//                let loginType = "Kakao"
//                self.showLoginError(loginType:loginType)
//            }
//        }
        
    }
//    
//    private func navigateToMainView() {
//        let mainVC = TabbarViewController()
//        mainVC.modalPresentationStyle = .fullScreen
//        self.present(mainVC, animated: false, completion: nil)
//    }
//    
//    private func showLoginError(loginType: String) {
//        let alert = UIAlertController(title: "Login Error", message: "Unable to login with \(loginType).", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        self.present(alert, animated: true, completion: nil)
//    }
}
