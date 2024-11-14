//
//  SocialLoginButton.swift
//  ReptileHub
//
//  Created by 임재현 on 8/7/24.
//

import UIKit
import SnapKit

enum LoginType: CaseIterable {
    case kakao, google, apple
    
    private enum Constants {
        static let googleTitle = "구글로 로그인"
        static let appleTitle = "애플로 로그인"
        static let iconSize: CGFloat = 45
        static let cornerRadius: CGFloat = 8
        static let horizontalPadding: CGFloat = 8
        static let trailingPadding: CGFloat = 32
    }
    
    var configuration: LoginButtonConfiguration {
        switch self {
        case .kakao:
            return LoginButtonConfiguration(icon: nil,
                                            backgroundImage: UIImage(named: "kakaoButton"),
                                            title: nil,
                                            backgroundColor: .clear,
                                            textColor: .clear,
                                            style: .backgroundImage)
        case .google:
            return LoginButtonConfiguration(icon: UIImage(named: "googleIcon"),
                                            backgroundImage: nil,
                                            title: Constants.googleTitle,
                                            backgroundColor: .googleBackgroundColor,
                                            textColor: .black,
                                            style: .iconWithText)
        case .apple:
            return LoginButtonConfiguration(icon: UIImage(named: "appleIcon"),
                                            backgroundImage: nil,
                                            title: Constants.appleTitle,
                                            backgroundColor: .black,
                                            textColor: .white,
                                            style: .iconWithText)
        }
    }
    
    
}

struct LoginButtonConfiguration {
    let icon: UIImage?
    let backgroundImage: UIImage?
    let title: String?
    let backgroundColor: UIColor
    let textColor: UIColor
    let style: LoginButtonStyle
    
    enum LoginButtonStyle {
        case backgroundImage
        case iconWithText
    }
}



final class SocialLoginButton: UIButton {
    private enum Constants {
        static let cornerRadius: CGFloat = 8
        static let iconSize: CGFloat = 45
        static let horizontalPadding: CGFloat = 8
        static let trailingPadding: CGFloat = 32
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let socialTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    init(configuration: LoginButtonConfiguration) {
        super.init(frame: .zero)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupWithConfiguration(_ configuration: LoginButtonConfiguration) {
        backgroundColor = configuration.backgroundColor
        layer.cornerRadius = Constants.cornerRadius
        
        switch configuration.style {
        case .backgroundImage:
            setImage(configuration.backgroundImage, for: .normal)
        case .iconWithText:
            setupIconWithTextStyle(icon: configuration.icon,
                                   title: configuration.title,
                                   textColor: configuration.textColor)
            
        }
    }
        
        private func setupIconWithTextStyle(icon: UIImage?, title: String?, textColor: UIColor) {
            addSubview(containerView)
            containerView.addSubview(iconImageView)
            containerView.addSubview(socialTitleLabel)
            
            iconImageView.image = icon
            socialTitleLabel.text = title
            socialTitleLabel.textColor = textColor
            
            setupConstraints()
        }
        
        private func setupConstraints() {
            containerView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            
            iconImageView.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.leading.equalToSuperview().offset(Constants.horizontalPadding)
                $0.width.height.equalTo(Constants.iconSize)
            }
            
            socialTitleLabel.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.leading.equalTo(iconImageView.snp.trailing).offset(Constants.horizontalPadding)
                $0.trailing.equalToSuperview().offset(-Constants.trailingPadding)
            }
        }
    }
        

extension UIColor {
    static let googleBackgroundColor = UIColor(red: 242 / 255.0,
                                   green: 242 / 255.0,
                                   blue: 242 / 255.0,
                                   alpha: 1.0)
    
}
