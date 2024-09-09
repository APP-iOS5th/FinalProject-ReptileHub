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

protocol EditUserInfoViewControllerDelegate: AnyObject {
    func tapSaveEditButton(newName: String, newProfileImage: UIImage)
}

class EditUserInfoViewController: UIViewController, UITextFieldDelegate {
    
    weak var delegate: EditUserInfoViewControllerDelegate?
    
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
    
    // MARK: - PHPicker
    @objc func selectImage() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images 
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self

        present(picker, animated: true, completion: nil)
    }
    
    // MARK: - 내용 변동이 있을 시 저장버튼 활성화
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
    
    // MARK: - 프로필 수정 저장 기능
    @objc func saveButtonTouch() {
        self.delegate?.tapSaveEditButton(newName: self.editUserInfoView.ProfileNameEdit.text ?? "nil", newProfileImage: self.editUserInfoView.ProfileImageEdit.image ?? UIImage(systemName: "person")!)
    }
    
    // MARK: - 프로필 수정 취소
    @objc func cancelButtonTouch() {
        dismiss(animated: true)
    }
}

// MARK: - PHPicker Delegate
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
                        self.isImageChanged = true
                        self.updateSaveButtonState()
                    }
                }
            }
        }
    }
}
