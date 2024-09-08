//
//  EditUserInfoView.swift
//  ReptileHub
//
//  Created by 육현서 on 8/26/24.
//

import UIKit
import SnapKit

class EditUserInfoView: UIView {
    
    let keyboardManager = KeyboardManager()
    
    // UserProfile 더미 데이터
//    let users: [UserProfile] = [
//        UserProfile(uid: "1001", providerUID: "123", name: "고앵이", profileImageURL: "profile", loginType: "profile2", lizardCount: 5, postCount: 12)
//    ]

    var ProfileImageEdit: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var imagePickerButton: UIButton = {
        let button = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        let image = UIImage(systemName: "pencil", withConfiguration: imageConfig)
                
        button.backgroundColor = .imagePicker
        button.layer.cornerRadius = CGFloat(15)
//        button.layer.borderColor = UIColor(.imagePicker).cgColor
//        button.layer.borderWidth = CGFloat(2)
        button.setImage(image, for: .normal)
        button.tintColor = .imagePickerPlaceholder
        
        return button
    }()
    
    var ProfileNameEdit: UITextField = {
       let textField = UITextField()
       textField.placeholder = "변경할 이름을 적어주세요."
       textField.borderStyle = .roundedRect
       return textField
    }()
    
    var UserInfoCancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 8
        return button
    }()
    
    var UserInfoSaveButton: UIButton = {
        let button = UIButton()
        button.setTitle("저장", for: .normal)
        button.backgroundColor = .addBtnGraphTabbar
        button.layer.cornerRadius = 8
        button.isEnabled = false  // 초기에는 비활성화
        button.alpha = 0.5  // 비활성화 상태를 시각적으로 표시
        return button
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [UserInfoCancelButton, UserInfoSaveButton])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        keyboardManager.delegate = self
        keyboardManager.showNoti()
        keyboardManager.hideNoti()
        
        setupView()
        setProfileImageEdit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        
        self.backgroundColor = .white
        self.addSubview(ProfileImageEdit)
        self.addSubview(imagePickerButton)
        self.addSubview(ProfileNameEdit)
        self.addSubview(buttonStackView)
//        self.addSubview(UserInfoCancelButton)
//        self.addSubview(UserInfoSaveButton)
        
        
        ProfileImageEdit.snp.makeConstraints { make in
            make.topMargin.equalTo(40)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        
        imagePickerButton.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.trailing.equalTo(ProfileImageEdit.snp.trailing).offset(3)
            make.bottom.equalTo(ProfileImageEdit.snp.bottom).offset(3)
        }
        
        ProfileNameEdit.snp.makeConstraints { make in
            make.top.equalTo(ProfileImageEdit.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
            make.height.equalTo(40)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(ProfileNameEdit.snp.bottom).offset(20)
            make.leading.trailing.equalTo(ProfileNameEdit)
        }
        
        UserInfoSaveButton.snp.makeConstraints { make in
//            make.top.equalTo(ProfileNameEdit.snp.bottom).offset(20)
//            make.trailing.equalToSuperview().offset(-40)
            
            make.width.lessThanOrEqualTo(150)
            make.height.equalTo(50)
        }
    
        UserInfoCancelButton.snp.makeConstraints { make in
//            make.top.equalTo(ProfileNameEdit.snp.bottom).offset(20)
//            make.leading.equalToSuperview().offset(40)
            make.width.lessThanOrEqualTo(150)
            make.height.equalTo(50)
        }
    }
    
    private func setProfileImageEdit() {
        ProfileImageEdit.image = UIImage(named: users[0].profileImageURL)
    }
}

extension EditUserInfoView: KeyboardNotificationDelegate {
    func keyboardWillShow(keyboardSize: CGRect) {
        print("keyboard Show")
        
        ProfileImageEdit.snp.remakeConstraints { make in
            make.topMargin.equalTo(100)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
//        self.frame.origin.y += 9999
        self.layoutIfNeeded()
    }
    
    func keyboardWillHide(keyboardSize: CGRect) {
        print("keyboard Hide")
        
        ProfileImageEdit.snp.remakeConstraints { make in
            make.topMargin.equalTo(40)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        self.layoutIfNeeded()

    }
}
