//
//  LoginViewController.swift
//  ReptileHub
//
//  Created by 임재현 on 8/7/24.
//

import UIKit

class LoginViewController: UIViewController {
    
    private let loginView = LoginView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupActions()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear")
//        loginView.kakaoButton.removeTarget(self, action: #selector(handleLogin(_:)), for: .touchUpInside)
//        loginView.googleButton.removeTarget(self, action: #selector(handleLogin(_:)), for: .touchUpInside)
//        loginView.appleButton.removeTarget(self, action: #selector(handleLogin(_:)), for: .touchUpInside)
    }
    
    private func setupView() {
        view.addSubview(loginView)
        loginView.snp.makeConstraints {
        $0.edges.equalToSuperview()
        }
    }
    
    private func setupActions() {
        loginView.kakaoButton.addTarget(self, action: #selector(handleLogin(_:)), for: .touchUpInside)
        loginView.googleButton.addTarget(self, action: #selector(handleLogin(_:)), for: .touchUpInside)
        loginView.appleButton.addTarget(self, action: #selector(handleLogin(_:)), for: .touchUpInside)
    }
    
    @objc func handleLogin(_ sender: UIButton) {
        if sender == loginView.kakaoButton {
            print("KaKao Login")
            kakaoLoginButtonTapped()
        } else if sender == loginView.googleButton {
            print("Google Login")
            googleLoginButtonTapped()
        } else if sender == loginView.appleButton {
            print("Apple Login")
            appleLoginButtonTapped()
        }
    }
    
    private func googleLoginButtonTapped() {
        print("google 버튼")
        AuthService.shared.loginWithGoogle(presentingViewController: self) { success in
            if success {
                self.navigateToMainView()
            } else {
                let loginType = "Google"
                self.showLoginError(loginType:loginType)
            }
        }
    }
    
    private func appleLoginButtonTapped() {
        print("apple 버튼")
        AuthService.shared.loginWithApple(presentingViewController: self) { success in
            if success {
                self.navigateToMainView()
            } else {
                let loginType = "Apple"
                self.showLoginError(loginType:loginType)
            }
        }
    }
    
    private func kakaoLoginButtonTapped() {
        print("kakao 버튼")
        AuthService.shared.loginWithKaKao(presentingViewController: self) { success in
            if success {
                self.navigateToMainView()
            } else {
                let loginType = "Kakao"
                self.showLoginError(loginType:loginType)
            }
        }
        
    }
    
    private func navigateToMainView() {
        let mainVC = TabbarViewController()
        mainVC.modalPresentationStyle = .fullScreen
        self.present(mainVC, animated: false, completion: nil)
    }
    
    private func showLoginError(loginType: String) {
        let alert = UIAlertController(title: "Login Error", message: "Unable to login with \(loginType).", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
