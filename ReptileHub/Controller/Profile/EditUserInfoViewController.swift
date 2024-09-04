//
//  EditUserInfoViewController.swift
//  Reptile_Hub_UI
//
//  Created by 육현서 on 8/8/24.
//

import UIKit
import SnapKit
import PhotosUI
import FirebaseAuth

class EditUserInfoViewController: UIViewController, UITextFieldDelegate {
    
    var editUserInfoData : (String, String)?
    var previousViewController: ProfileViewController?
    
    private let editUserInfoView = EditUserInfoView()
    private let profileView = ProfileViewController()
    
    private var isImageChanged = false  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editUserInfoView.ProfileNameEdit.delegate = self
                
        self.view.backgroundColor = .white
        self.view = editUserInfoView
        
        editUserInfoView.imagePickerButton.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
        editUserInfoView.ProfileNameEdit.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        editUserInfoView.UserInfoCancelButton.addTarget(self, action: #selector(cancelButtonTouch), for: .touchUpInside)
        editUserInfoView.UserInfoSaveButton.addTarget(self, action: #selector(saveButtonTouch), for: .touchUpInside)
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        editUserInfoView.setProfileImageEdit(imageName: editUserInfoData!.1, name: editUserInfoData!.0)
    }
    
    @objc func selectImage() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images  // 이미지 필터링 설정
        configuration.selectionLimit = 1  // 한 번에 하나의 이미지 선택

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self

        present(picker, animated: true, completion: nil)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        updateSaveButtonState()
    }
    
    private func updateSaveButtonState() {
        let isTextEntered = !(editUserInfoView.ProfileNameEdit.text?.isEmpty ?? true)
        let shouldEnableSaveButton = isTextEntered || isImageChanged
        editUserInfoView.UserInfoSaveButton.isEnabled = shouldEnableSaveButton
        editUserInfoView.UserInfoSaveButton.alpha = shouldEnableSaveButton ? 1.0 : 0.5
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func saveButtonTouch() {
        print("저장 ~")
        guard let uid = Auth.auth().currentUser?.uid else {return}
        UserService.shared.updateUserProfile(uid: uid, newName: editUserInfoView.ProfileNameEdit.text, newProfileImage: editUserInfoView.ProfileImageEdit.image) { [weak self] error in
            if let error = error {
                print("error\(error.localizedDescription)")
            } else {
                print("놀고 싶 다")
                if let previousVC = self?.previousViewController{
                                    print("privousVC", previousVC)
                                    previousVC.updateImage()
                                }
                self?.dismiss(animated: true)
                self?.editUserInfoData = nil
            }
        }
    }
    
    @objc func cancelButtonTouch() {
        print("취소 ~")
        dismiss(animated: true)
    }
}

extension EditUserInfoViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let result = results.first else { return }
        
        if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error loading image: \(error.localizedDescription)")
                    return
                }
                if let image = image as? UIImage {
                    DispatchQueue.main.async {
                        self.editUserInfoView.ProfileImageEdit.image = image
                        self.isImageChanged = true  // 이미지가 변경되었음을 표시
                        self.updateSaveButtonState()
                    }
                }
            }
        }
    }
}
