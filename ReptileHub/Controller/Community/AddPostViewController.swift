//
//  AddPostViewController.swift
//  ReptileHub
//
//  Created by 조성빈 on 8/23/24.
//

import UIKit
import PhotosUI
import FirebaseAuth

protocol AddPostViewControllerDelegate: AnyObject {
    func dismissAddPost(detailPostData: PostDetailResponse)
}

class AddPostViewController: UIViewController {
    let customIndicator = CustomActivityIndicator()
    weak var delegate: AddPostViewControllerDelegate?
    
    private let addPostView = AddPostView()
    
    var postId: String
    
    var editMode: Bool
    
    var editResponse: PostDetailResponse?
    
    var originalImageURLs: [String] = []
    
    var removedImageURLs: [String] = []
    
    init(postId: String, editMode: Bool) {
        print("이닛!!")
        self.postId = postId
        self.editMode = editMode
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("으아아아아아아아악!!")
        print("첫번째. AddPostVC 나타남. editMode: \(editMode)")
        print("넘겨받은 게시글 정보 : \(postId)")
        
        
        
        if self.editMode {
            CommunityService.shared.fetchPostDetail(userID: UserService.shared.currentUserId, postID: postId) { result in
                switch result {
                case .success(let postDetail):
                    self.editResponse = postDetail
                        if let editResponse = self.editResponse {
                            self.originalImageURLs = editResponse.imageURLs
                            self.addPostView.configureEdit(configureEditData: editResponse)
                        }
                case .failure(let error):
                    print("에러에러 : \(error.localizedDescription)")
                }
            }
        }
        
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view = addPostView
        addPostView.configureAddPostView(delegate: self, datasource: self, textViewDelegate: self)
        
        // 등록하기 버튼 델리겟
        addPostView.delegate = self
        
        navigationItem.title = editMode ? "게시글 수정" : "게시글 작성"
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
    // 텍스트 뷰의 텍스트가 변경될 때 호출되는 델리게이트 메서드
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
            // 이미지 배열 첫번째는 선택 버튼이라 빼준다.
            let index = indexPath.item - 1
            // 삭제할 이미지의 인덱스가 선택된 이미지들의 개수보다 작다면
            if index < addPostView.selectedImages.count {
                // 만약 삭제할 이미지가 기존의 이미지라면
                if index < originalImageURLs.count {
                    // 삭제할 이미지URL을 변수에 저장
                    let removedImageURL = originalImageURLs[index]
                    removedImageURLs.append(removedImageURL) // 삭제해야될 url 들을 배열에 저장해서 관리
                    originalImageURLs.remove(at:index) // 기존 이미지 URL에서 제거
                } else {
                    let newImageIndex = index - originalImageURLs.count
                    // 새로운 이미지의 경우, ImagesData에서 제거 - 기존 이미지 뒤에 새로 선택한 사진이 나옴(imageData)
                    addPostView.imageData.remove(at: newImageIndex)
                }
                // 선택된 배열 목록에서 해당 인덱스 제거
                addPostView.selectedImages.remove(at: index)
                addPostView.imagePickerCollectionView.reloadData()
            }
        }
    
}


extension AddPostViewController: AddPostViewDelegate {
    func didTapPostButton(imageData: [Data], title: String, content: String) {
        guard let userID = Auth.auth().getUserID() else {
            return
        }
        if editMode {
            guard let editResponse = self.editResponse else { return }
            CommunityService.shared.updatePost(postID: editResponse.postID, userID: editResponse.userID, newTitle: title, newContent: content, newImages: imageData, existingImageURLs: originalImageURLs, removedImageURLs: removedImageURLs) { error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("업데이트 완료")

                    CommunityService.shared.fetchPostDetail(userID: UserService.shared.currentUserId, postID: editResponse.postID) { result in
                        switch result {
                        case .success(let success):                            self.delegate?.dismissAddPost(detailPostData: success)
                            self.navigationController?.popViewController(animated: true)

                        case .failure(let failure):
                            print("에러다!!!!!!!")
                        }
                    }

                }
            }
        }
        else {
            print("""
                    [현재 등록할 게시글 내용]
                    userid: \(Auth.auth().currentUser?.uid)
                    imageData: \(imageData)
                    title: \(title)
                    content: \(content)
                    """)
            
            CommunityService.shared.createPost(userID: Auth.auth().currentUser!.uid, title: title, content: content, images: imageData) { error in
                if let error = error {
                            print("게시글 게시 중 오류 발생: \(error.localizedDescription)")
                        } else {
                            print("게시글 게시 성공")
                            self.navigationController?.popViewController(animated: true)
                        }
            }
        }
    }
}
