//
//  SocialLoginButton.swift
//  ReptileHub
//
//  Created by 임재현 on 8/7/24.
//

import UIKit
import SnapKit

enum LoginType {
    case kakao,google,apple
    
    var icon:UIImage? {
        switch self {
        case .kakao:
            return nil
        case .google:
            return UIImage(named:"googleIcon")
        case .apple:
            return UIImage(named:"appleIcon")
        }
    }
    
    var backgroundImage:UIImage? {
        switch self {
        case .kakao:
            return UIImage(named: "kakaoButton")
        case .google,.apple:
            return nil
        }
    }
    
    var title: String? {
        switch self {
        case .kakao:
            return nil
        case .google:
            return "구글로 로그인"
        case .apple:
            return "애플로 로그인"
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .kakao:
            return .clear
        case .google:
            return .googleBackgroundColor
        case .apple:
            return .black
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .kakao:
            return .clear
        case .google:
            return .black
        case .apple:
            return .white
        }
    }
    
}





class SocialLoginButton:UIButton {
    
    init(icon:UIImage,title:String,backgroundColor:UIColor,textColor:UIColor) {
        super.init(frame: .zero)
        
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = 8
        
        let containerView = UIView()
        containerView.isUserInteractionEnabled = false
        self.addSubview(containerView)
        
        let iconImageView = UIImageView(image: icon)
        iconImageView.contentMode = .scaleAspectFit
        containerView.addSubview(iconImageView)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = textColor
        titleLabel.textAlignment = .center
        containerView.addSubview(titleLabel)
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(8)
            $0.width.height.equalTo(45)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(iconImageView.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-32)
        }
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension UIColor {
    static let googleBackgroundColor = UIColor(red: 242 / 255.0,
                                   green: 242 / 255.0,
                                   blue: 242 / 255.0,
                                   alpha: 1.0)
    
}
