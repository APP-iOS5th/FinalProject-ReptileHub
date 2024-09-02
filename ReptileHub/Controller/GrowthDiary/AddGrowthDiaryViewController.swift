//
//  AddGrowthDiaryViewController.swift
//  ReptileHub
//
//  Created by 이상민 on 8/27/24.
//

import UIKit
import PhotosUI
import FirebaseAuth

class AddGrowthDiaryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var previousViewController: GrowthDiaryViewController?

    private lazy var addGrowthDiaryView = AddGrowthDiaryView()
    private var selectedImageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUP()
    }
    
    func setUP(){
        self.title = "성장일지"
        self.view = addGrowthDiaryView
        self.view.backgroundColor = .white
        
        let action = UIAction{ [weak self] _ in
            self?.datePickerValueChanged()
        }
        addGrowthDiaryView.addAction(action: action)
        
        addGrowthDiaryView.configureImageViewActions(target: self, action: #selector(imageViewTapped(_:)))
        
        addGrowthDiaryView.buttonTapped = { [weak self] in
            self?.uploadGrowthDiary()
        }
    }
    
    private func uploadGrowthDiary(){
        guard let userId = Auth.auth().getUserID() else {
            return
        }
        let result = addGrowthDiaryView.growthDiaryRequestData()
        print(result.1)
        DiaryPostService.shared.registerGrowthDiary(userID: userId, diary: result.0, selfImageData: result.1[0], motherImageData: result.1[1], fatherImageData: result.1[2]) { [weak self] error in
            if let error = error{
                print("error", error.localizedDescription)
            }else{
                print("Success")
                if let previousVC = self?.previousViewController{
                    print("privousVC", previousVC)
                    previousVC.updateImage()
                }
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func datePickerValueChanged(){
        addGrowthDiaryView.updateDateField()
    }
    
    
    @objc private func imageViewTapped(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
        
        guard let tappedImageView = sender.view as? UIImageView else { return }
        
        selectedImageView = tappedImageView
        
        let photoLibrary = PHPhotoLibrary.shared()
        var config = PHPickerConfiguration(photoLibrary: photoLibrary)
        config.filter = .images
        config.selectionLimit = 1
        
        // UIImagePickerController 설정
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
}

extension AddGrowthDiaryViewController: PHPickerViewControllerDelegate{
    // PHPickerViewControllerDelegate 메서드: 이미지가 선택되었을 때 호출됩니다.
       func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
           picker.dismiss(animated: true, completion: nil)
           
           guard let selectedImageView = selectedImageView else { return }
           
           // 첫 번째 선택된 이미지를 가져와 설정
           if let result = results.first {
               result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
                   guard let self = self, let image = object as? UIImage, error == nil else {
                       print("Error loading image: \(String(describing: error))")
                       return
                   }
                   
                   DispatchQueue.main.async {
                       self.addGrowthDiaryView.setImage(image, for: selectedImageView)
                   }
               }
           }
       }
}

#if DEBUG
import SwiftUI
struct AddViewControllerRepresentable: UIViewControllerRepresentable {
    
    func updateUIViewController(_ uiView: UIViewController,context: Context) {
        // leave this empty
    }
    @available(iOS 13.0.0, *)
    func makeUIViewController(context: Context) -> UIViewController{
        AddGrowthDiaryViewController()
    }
}
@available(iOS 13.0, *)
struct AddViewControllerRepresentable_PreviewProvider: PreviewProvider {
    static var previews: some View {
        Group {
            AddViewControllerRepresentable()
                .ignoresSafeArea()
                .previewDisplayName(/*@START_MENU_TOKEN@*/"Preview"/*@END_MENU_TOKEN@*/)
                .previewDevice(PreviewDevice(rawValue: "iPhone 15 Pro"))
        }
        
    }
} #endif
