//
//  EditUserInfoViewController.swift
//  Reptile_Hub_UI
//
//  Created by 육현서 on 8/8/24.
//

import UIKit
import SnapKit

class EditUserInfoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    private let editUserInfoView = EditUserInfoView()
    
    private var isImageChanged = false  // 이미지가 변경되었는지 확인하는 플래그
    
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
    
    @objc func selectImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = .camera

        present(imagePickerController, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            editUserInfoView.ProfileImageEdit.image = selectedImage
            isImageChanged = true  // 이미지가 변경되었음을 표시
            updateSaveButtonState()
        }
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
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
