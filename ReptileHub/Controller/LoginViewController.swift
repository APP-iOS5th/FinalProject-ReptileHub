//
//  LoginViewController.swift
//  ReptileHub
//
//  Created by 임재현 on 8/7/24.
//

import UIKit
import SnapKit

class LoginViewController: UIViewController {
    private let logoImageView = UIImageView()
    private let lineView = UIView()
    private let stackView = UIStackView()
    
    private lazy var kakaoButton = createButton(for: .kakao)
    private lazy var googleButton = createButton(for: .google)
    private lazy var appleButton = createButton(for: .apple)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    func configUI() {
        view.backgroundColor = .white
        
        view.addSubview(logoImageView)
        view.addSubview(lineView)
        
        logoImageView.image = UIImage(named: "LogoImage")
        logoImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(80)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(273)
            $0.height.equalTo(202)
        }
        
        lineView.backgroundColor = .gray
        
        lineView.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(1)
            $0.leading.equalToSuperview().offset(80)
        }
        
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.alignment = .center
        
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(lineView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
        
        stackView.addArrangedSubview(kakaoButton)
        stackView.addArrangedSubview(googleButton)
        stackView.addArrangedSubview(appleButton)
        
        setButtonConstraints(kakaoButton)
        setButtonConstraints(googleButton)
        setButtonConstraints(appleButton)
        
        
    }
    
    
    private func createButton(for type:LoginType) -> UIButton {
        if type == .kakao {
            let button = UIButton()
            button.setImage(type.backgroundImage, for: .normal)
            button.backgroundColor = type.backgroundColor
            button.layer.cornerRadius = 8
            button.addTarget(self, action: #selector(handleLogin(_:)), for: .touchUpInside)
            button.showsTouchWhenHighlighted = false
            button.adjustsImageWhenHighlighted = false
            return button
        } else {
            let button = SocialLoginButton(icon: type.icon!, title: type.title!, backgroundColor: type.backgroundColor, textColor: type.textColor)
                button.addTarget(self, action: #selector(handleLogin(_:)), for: .touchUpInside)
                return button
        }
    }
    
    private func setButtonConstraints(_ button:UIButton) {
        button.snp.makeConstraints {
            $0.width.equalTo(344)
            $0.height.equalTo(52)
        }
    }
    
    private func navigateToMainView() {
        let mainVC = ViewController()
        mainVC.modalPresentationStyle = .fullScreen
        self.present(mainVC,animated: false,completion: nil)
    }
    
    private func showLoginError() {
        let alert = UIAlertController(title: "Login Error", message: "Unable to login with Google.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func googleLoginButtonTapped() {
        AuthService.shared.loginWithGoogle(presentingViewController: self) { success in
            if success {
                self.navigateToMainView()
            } else {
                self.showLoginError()
            }
        }
    }
    
    
    
    
    @objc func handleLogin(_ sender:UIButton) {
        if sender == kakaoButton {
            print("KaKao Login")
        } else if sender == googleButton {
            print("Google Login")
            googleLoginButtonTapped()
        } else if sender == appleButton {
            print("Apple Login")
        }
    }
    
    
}
