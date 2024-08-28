//
//  AddPostViewController.swift
//  ReptileHub
//
//  Created by 조성빈 on 8/23/24.
//

import UIKit
import PhotosUI

class AddPostViewController: UIViewController {
    
    private let addPostView = AddPostView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        self.view = addPostView
        addPostView.configureAddPostView(delegate: self, datasource: self, phpickerDelegate: self)
    }
    
    
    
}


extension AddPostViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return addPostView.selectedImages.count + 1 // 첫 셀은 PH피커이므로 + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PHPickerCell", for: indexPath) as! PHPickerCollectionViewCell
        
        if indexPath.item == 0 {
            cell.imageView.image = UIImage(systemName: "camera")
            cell.deleteButton.isHidden = true
        } else {
            cell.imageView.image = addPostView.selectedImages[indexPath.item - 1]
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            addPostView.addImageButtonTapped()
            present(addPostView.picker, animated: true, completion: nil)
        }
    }
}

extension AddPostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        print("사진 선택완료~")
        picker.dismiss(animated: true, completion: nil)
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                guard let self = self else { return }
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        // 피커에서 추가로 이미지 선택할 경우 이미지 배열에 추가해서 선택한 사진 바로 리로드
                        self.addPostView.selectedImages.append(image)
                        self.addPostView.imagePickerCollectionView.reloadData()
                    }
                }
            }
        }
    }
    
}
