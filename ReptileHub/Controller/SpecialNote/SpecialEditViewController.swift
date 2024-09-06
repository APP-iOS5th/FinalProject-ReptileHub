//
//  SpecialEditViewController.swift
//  ReptileHub
//
//  Created by 황민경 on 8/21/24.
//

import UIKit
import SnapKit
import PhotosUI

class SpecialEditViewController: UIViewController {
    
    private let specialEditView = SpecialEditView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = specialEditView
        specialEditView.configureSpecialEditView(delegate: self, datasource: self, textViewDelegate: self)
        navigationItem.title = "특이사항"
        // Do any additional setup after loading the view.
    }

}
//MARK: - SpecialEditView Image CollectionViewDelegate 관련
extension SpecialEditViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return specialEditView.selectedImages.count + 1 // 첫 셀은 PH피커이므로 + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PHPickerCell", for: indexPath) as! SpecialPHPickerCollectionViewCell
        
        if indexPath.item == 0 {
            let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .light)
            let cameraImage = UIImage(systemName: "camera", withConfiguration: config)
            cell.imageView.image = cameraImage
            cell.imageView.contentMode = .center
            cell.deleteButton.isHidden = true
        } else {
            cell.imageView.image = specialEditView.selectedImages[indexPath.item - 1]
            cell.imageView.contentMode = .scaleAspectFill
            cell.delegate = self
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            let picker = specialEditView.createPHPickerVC()
            picker.delegate = self
            present(picker, animated: true, completion: nil)
        }
    }
}
//MARK: - SpecialEditView Image PHPickerCollectionViewDelegate 관련
extension SpecialEditViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        print("사진 선택완료~")
        picker.dismiss(animated: true, completion: nil)
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                guard let self = self else { return }
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        // 피커에서 추가로 이미지 선택할 경우 이미지 배열에 추가해서 선택한 사진 바로 리로드
                        if self.specialEditView.selectedImages.count < 5{
                            self.specialEditView.selectedImages.append(image)
                            self.specialEditView.imagePickerCollectionView.reloadData()
                            
                            if let imageData = image.jpegData(compressionQuality: 0.8) {
                                self.specialEditView.imageData.append(imageData)
                            }
                            
                        } else {
                            print("이미 선택된 이미지가 5개 입니다.")
                            return
                        }
                    }
                }
            }
        }
    }
    
}
//MARK: - SpecialEditView Image PHPickerCollectionViewCellDelegate 관련
extension SpecialEditViewController: SpecialPHPickerCollectionViewCellDelegate {
    
    func didTapDeleteButton(indexPath: IndexPath) {
        print("콜렉션 뷰 셀 삭제버튼 클릭.")
        
        self.specialEditView.selectedImages.remove(at: indexPath.item - 1)
        self.specialEditView.imagePickerCollectionView.reloadData()
        print("콜렉션 뷰 셀 삭제 후 selectedImages : \(self.specialEditView.selectedImages)")
    }
    
}

//MARK: -  textview placeholder
extension SpecialEditViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == "" {
            self.specialEditView.textViewPlaceholder.isHidden = false
        } else {
            self.specialEditView.textViewPlaceholder.isHidden = true
        }
    }
}


