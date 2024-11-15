//
//  LoginView.swift
//  ReptileHub
//
//  Created by 임재현 on 8/13/24.
//

import UIKit
import SnapKit
import Combine

class LoginView: UIView {
    let loginButtonTapPublisher = PassthroughSubject<LoginType, Never>()
    
    private enum Constants {
        static let logoTopOffset: CGFloat = 80
        static let logoWidth: CGFloat = 273
        static let logoHeight: CGFloat = 202
        static let lineTopOffset: CGFloat = 4
        static let lingLeadingOffset: CGFloat = 80
        static let lineHeight: CGFloat = 1
        static let stackViewTopOffset: CGFloat = 20
        static let stackViewSpacing: CGFloat = 15
        static let buttonWidth: CGFloat = 344
        static let buttonHeight: CGFloat = 52
    }
    
    private let buttons: [SocialLoginButton]
    private let logoImageView = UIImageView(image: UIImage(named: "LogoImage"))
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        return view
    }()
    
    private let socialButtonStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Constants.stackViewSpacing
        stack.alignment = .center
        return stack
    }()
    
    
    override init(frame: CGRect) {
        self.buttons = LoginType.allCases.map { type in
            SocialLoginButton(configuration: type.configuration)
        }
        super.init(frame: frame)
        configureUI()
        print("LoginView init()")
        setupButtonActions()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        backgroundColor = .white
        setupLogoImage()
        setupLineView()
        setupSocialButtonStackView()
    }
    
    private func setupLogoImage() {
        addSubview(logoImageView)
        
        logoImageView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(Constants.logoTopOffset)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(Constants.logoWidth)
            $0.height.equalTo(Constants.logoHeight)
        }
    }
    
    private func setupLineView() {
        addSubview(lineView)
        
        lineView.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(Constants.lineTopOffset)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(Constants.lineHeight)
            $0.leading.equalToSuperview().offset(Constants.lingLeadingOffset)
        }
    }
    
    private func setupSocialButtonStackView() {
        addSubview(socialButtonStackView)
        
        buttons.forEach { button in
            socialButtonStackView.addArrangedSubview(button)
            setButtonConstraints(button)
        }
        
        socialButtonStackView.snp.makeConstraints {
            $0.top.equalTo(lineView.snp.bottom).offset(Constants.stackViewTopOffset)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func setButtonConstraints(_ button: UIButton) {
        button.snp.makeConstraints {
            $0.width.equalTo(Constants.buttonWidth)
            $0.height.equalTo(Constants.buttonHeight)
        }
    }
    
    private func setupButtonActions() {
        buttons.forEach { button in
            button.addAction(
                UIAction { [weak self] _ in
                    print("button Tapped:\(button.socialConfig.type)")
                    self?.loginButtonTapPublisher.send(button.socialConfig.type)
            }, for: .touchUpInside)
        }
    }
    
    
    
    
    
}

