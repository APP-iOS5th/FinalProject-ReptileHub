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
        addPostView.configureAddPostView(delegate: self, datasource: self, textViewDelegate: self)
        
        // 등록하기 버튼 델리겟
        addPostView.delegate = self
    }
    
    
    
}


extension AddPostViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return addPostView.selectedImages.count + 1 // 첫 셀은 PH피커이므로 + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PHPickerCell", for: indexPath) as! PHPickerCollectionViewCell
        
        if indexPath.item == 0 {
            let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .light)
            let cameraImage = UIImage(systemName: "camera", withConfiguration: config)
            cell.imageView.image = cameraImage
            cell.imageView.contentMode = .center
            cell.deleteButton.isHidden = true
        } else {
            cell.imageView.image = addPostView.selectedImages[indexPath.item - 1]
            cell.imageView.contentMode = .scaleAspectFill
            cell.delegate = self
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            let picker = addPostView.createPHPickerVC()
            picker.delegate = self
            present(picker, animated: true, completion: nil)
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
                        if self.addPostView.selectedImages.count < 5{
                            self.addPostView.selectedImages.append(image)
                            self.addPostView.imagePickerCollectionView.reloadData()
                            
                            if let imageData = image.jpegData(compressionQuality: 0.8) {
                                self.addPostView.imageData.append(imageData)
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

extension AddPostViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == "" {
            self.addPostView.textViewPlaceholder.isHidden = false
        } else {
            self.addPostView.textViewPlaceholder.isHidden = true
        }
    }
}


extension AddPostViewController: PHPickerCollectionViewCellDelegate {
    
    func didTapDeleteButton(indexPath: IndexPath) {
        print("콜렉션 뷰 셀 삭제버튼 클릭.")
        
        self.addPostView.selectedImages.remove(at: indexPath.item - 1)
        self.addPostView.imagePickerCollectionView.reloadData()
        print("콜렉션 뷰 셀 삭제 후 selectedImages : \(self.addPostView.selectedImages)")
    }
    
}


extension AddPostViewController: AddPostViewDelegate {
    func didTapPostButton(imageData: [Data], title: String, content: String) {
        print("""
                [현재 등록할 게시글 내용]
                imageData: \(imageData)
                title: \(title)
                content: \(content)
                """)
        let userID = "임시로 지정"
        
//        CommunityService.shared.createPost(userID: userID, title: title, content: content, images: imageData) { error in
//            if let error = error {
//                        print("게시글 게시 중 오류 발생: \(error.localizedDescription)")
//                    } else {
//                        print("게시글 게시 성공")
//                    }
//        }
    }
    
    
}
