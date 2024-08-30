//
//  EditUserInfoViewController.swift
//  Reptile_Hub_UI
//
//  Created by 육현서 on 8/8/24.
//

import UIKit
import SnapKit

class EditUserInfoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()
    
    private var contentView: UIView = UIView()
    
    private var ProfileImageEdit: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "profile")
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private var imagePickerButton: UIButton = {
        let button = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        let image = UIImage(systemName: "pencil", withConfiguration: imageConfig)
                
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = CGFloat(15)
        button.layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        button.layer.borderWidth = CGFloat(2)
        button.setImage(image, for: .normal)
        button.tintColor = .black
        
        button.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
        return button
    }()
    
    private var ProfileNameEdit: UITextField = {
       let textField = UITextField()
       textField.placeholder = "변경할 이름을 적어주세요."
       textField.borderStyle = .roundedRect
       textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
       return textField
    }()
    
    private var UserInfoCancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(cancelButtonTouch), for: .touchUpInside)
        return button
    }()
    
    private var UserInfoSaveButton: UIButton = {
        let button = UIButton()
        button.setTitle("저장", for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 8
        button.isEnabled = false  // 초기에는 비활성화
        button.alpha = 0.5  // 비활성화 상태를 시각적으로 표시
        button.addTarget(self, action: #selector(saveButtonTouch), for: .touchUpInside)
        return button
    }()
    
    private var isImageChanged = false  // 이미지가 변경되었는지 확인하는 플래그
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ProfileNameEdit.delegate = self
                
        self.view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(ProfileImageEdit)
        contentView.addSubview(imagePickerButton)
        contentView.addSubview(ProfileNameEdit)
        contentView.addSubview(UserInfoCancelButton)
        contentView.addSubview(UserInfoSaveButton)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(400) // 임의의 높이, 스크롤이 가능하도록
        }
        
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
        
        UserInfoSaveButton.snp.makeConstraints { make in
            make.top.equalTo(ProfileNameEdit.snp.bottom).offset(20)
            make.trailing.equalToSuperview().offset(-40)
            make.width.equalTo(150)
            make.height.equalTo(50)
        }
    
        UserInfoCancelButton.snp.makeConstraints { make in
            make.top.equalTo(ProfileNameEdit.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(40)
            make.width.equalTo(150)
            make.height.equalTo(50)
        }
        
        // 키보드 노티피케이션 옵저버 추가
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func selectImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = false

        present(imagePickerController, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            ProfileImageEdit.image = selectedImage
            isImageChanged = true  // 이미지가 변경되었음을 표시
            updateSaveButtonState()
        }
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            
            // 키보드가 나타나면 scrollView의 inset을 조정
            scrollView.contentInset.bottom = keyboardHeight
            scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        // 키보드가 사라지면 inset을 원래대로 되돌림
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        updateSaveButtonState()
    }
    
    private func updateSaveButtonState() {
        let isTextEntered = !(ProfileNameEdit.text?.isEmpty ?? true)
        let shouldEnableSaveButton = isTextEntered || isImageChanged
        UserInfoSaveButton.isEnabled = shouldEnableSaveButton
        UserInfoSaveButton.alpha = shouldEnableSaveButton ? 1.0 : 0.5
    }
    
    // MARK: - 키보드 return 누르면 내려가는 기능
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func saveButtonTouch() {
        print("저장 ~")
    }
    
    @objc func cancelButtonTouch() {
        print("취소 ~")
        dismiss(animated: true)
    }
}
