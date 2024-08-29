//
//  PhotoPickerManager.swift
//  ReptileHub
//
//  Created by 이상민 on 8/29/24.
//

import UIKit
import PhotosUI

import UIKit
import PhotosUI

class PhotoPickerManager: NSObject, PHPickerViewControllerDelegate {

    private var compoletion: (([UIImage]) -> Void)?

    func presentPhotoPicker(from viewController: UIViewController, completition: @escaping ([UIImage]) -> Void) {
        self.compoletion = completition
        
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 0 // 여러 이미지를 선택할 수 있도록 무제한 설정
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        
        viewController.present(picker, animated: true, completion: nil)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)

        var selectedImages: [UIImage] = []
        let dispatchGroup = DispatchGroup()

        for result in results {
            dispatchGroup.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                if let selectedImage = image as? UIImage, error == nil {
                    selectedImages.append(selectedImage)
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.compoletion?(selectedImages)
        }
    }
}
