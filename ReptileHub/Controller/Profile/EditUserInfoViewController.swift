//
//  EditUserInfoViewController.swift
//  Reptile_Hub_UI
//
//  Created by 육현서 on 8/8/24.
//

import UIKit
import SnapKit
import PhotosUI

class EditUserInfoViewController: UIViewController, UITextFieldDelegate {
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
