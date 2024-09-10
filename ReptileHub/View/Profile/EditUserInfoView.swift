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

    // MARK: - 프로필 수정 뷰 구성요소
    // 수정 전/후 이미지 뷰
    var ProfileImageEdit: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        return imageView
    }()
    
    // 프로필 이미지 수정 버튼 (PHPicker 버튼)
    var imagePickerButton: UIButton = {
        let button = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        let image = UIImage(systemName: "pencil", withConfiguration: imageConfig)
                
        button.backgroundColor = .imagePicker
        button.layer.cornerRadius = CGFloat(15)
        button.setImage(image, for: .normal)
        button.tintColor = .imagePickerPlaceholder
        return button
    }()
    
    // 프로필 이름 수정
    var ProfileNameEdit: UITextField = {
       let textField = UITextField()
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.cornerRadius = 8.0
        textField.layer.masksToBounds = true
        textField.textColor = .black
        textField.attributedPlaceholder = NSAttributedString(
              string: "변경할 이름을 적어주세요.",
              attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
          )
       return textField
    }()
    
    // 취소 버튼
    var UserInfoCancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 8
        return button
    }()
    
    // 저장 버튼
    var UserInfoSaveButton: UIButton = {
        let button = UIButton()
        button.setTitle("저장", for: .normal)
        button.backgroundColor = .addBtnGraphTabbar
        button.layer.cornerRadius = 8
        button.isEnabled = false
        button.alpha = 0.5
        return button
    }()
    
    // 취소, 저장 버튼 스택뷰
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 뷰 구성 메소드
    private func setupView() {
        self.backgroundColor = .white
        
        self.addSubview(ProfileImageEdit)
        self.addSubview(imagePickerButton)
        self.addSubview(ProfileNameEdit)
        self.addSubview(buttonStackView)
        
        ProfileNameEdit.backgroundColor = .white
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
            make.width.lessThanOrEqualTo(150)
            make.height.equalTo(50)
        }
    
        UserInfoCancelButton.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(150)
            make.height.equalTo(50)
        }
    }
   
    // MARK: - 기존 프로필 이미지, 이름 데이터
    func setProfileImageEdit(imageName: String?, name: String?) {
        ProfileImageEdit.setImage(with: imageName!)
        ProfileNameEdit.text = name
        ProfileNameEdit.textAlignment = .center
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
