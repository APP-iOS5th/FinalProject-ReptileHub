//
//  LoginView.swift
//  ReptileHub
//
//  Created by 임재현 on 8/13/24.
//

import UIKit
import SnapKit

class LoginView: UIView {
    

    let logoImageView = UIImageView()
    let lineView = UIView()
    let stackView = UIStackView()
    
    let kakaoButton: UIButton
    let googleButton: UIButton
    let appleButton: UIButton
    

    override init(frame: CGRect) {
        kakaoButton = LoginView.createButton(for: .kakao)
        googleButton = LoginView.createButton(for: .google)
        appleButton = LoginView.createButton(for: .apple)
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        backgroundColor = .white
        
        addSubview(logoImageView)
        addSubview(lineView)
        addSubview(stackView)
        
        logoImageView.image = UIImage(named: "LogoImage")
        logoImageView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(80)
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
        stackView.addArrangedSubview(kakaoButton)
        stackView.addArrangedSubview(googleButton)
        stackView.addArrangedSubview(appleButton)
        
        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalTo(lineView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
        
        setButtonConstraints(kakaoButton)
        setButtonConstraints(googleButton)
        setButtonConstraints(appleButton)
    }
    
    private static func createButton(for type: LoginType) -> UIButton {
        if type == .kakao {
            let button = UIButton()
            button.setImage(type.backgroundImage, for: .normal)
            button.backgroundColor = type.backgroundColor
            button.layer.cornerRadius = 8
            button.showsTouchWhenHighlighted = false
            button.adjustsImageWhenHighlighted = false
            return button
        } else {
            return SocialLoginButton(icon: type.icon!, title: type.title!, backgroundColor: type.backgroundColor, textColor: type.textColor)
        }
    }
    
    private func setButtonConstraints(_ button: UIButton) {
        button.snp.makeConstraints {
            $0.width.equalTo(344)
            $0.height.equalTo(52)
        }
    }
}

