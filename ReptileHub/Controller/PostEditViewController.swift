//
//  PostEditViewController.swift
//  ReptileHub
//
//  Created by 임재현 on 8/23/24.
//

import UIKit
import PhotosUI

class PostEditViewController: UIViewController, PHPickerViewControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    var postDetail: PostDetailResponse? // details 에서 받은 response 값 받음
    var originalImageURLs: [String] = [] // details 에서 받은 imageurls 를 넘겨받아서 배열로 저장
    var images: [UIImage?] = []  // details 에서  imageURL -> 이미지 다운로드 후 해당 이미지 파일 자체로 전송 ( 다시 urlSession 으로 다운받을 필요 x)
    var newImagesData: [Data] = [] // 새로 이미지 피커에서 선택한 사진은 storage에 저장하고 url 을 받아야 하므로 여기 배열에 저장해서 관리
    var removedImageURLs: [String] = [] // 기존의 이미지 에서 삭제를 할 경우에 해당 사진의 url 및 storage 에 저장된 사진 삭제를 위해 이 배열에 넣어서 처리

    private var imagePickerCollectionView: UICollectionView!
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "제목을 입력해주세요."
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let contentTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 8.0
        return textView
    }()
    
    private let completeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("수정완료", for: .normal)
        button.backgroundColor = UIColor.systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8.0
        return button
    }()
    
    override func viewWillAppear(_ animated: Bool) {
//        setupUI()
//        setupConstraints()
//        populateData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupConstraints()
        populateData()
    }
    
    private func setupUI() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.itemSize = CGSize(width: 80, height: 80)
        
        imagePickerCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        imagePickerCollectionView.backgroundColor = .white
        imagePickerCollectionView.delegate = self
        imagePickerCollectionView.dataSource = self
        imagePickerCollectionView.register(ImagePickerCollectionViewCell.self, forCellWithReuseIdentifier: "ImagePickerCell")
        
        view.addSubview(imagePickerCollectionView)
        view.addSubview(titleTextField)
        view.addSubview(contentTextView)
        view.addSubview(completeButton)
        
        completeButton.addTarget(self, action: #selector(handleCompleteButtonTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        imagePickerCollectionView.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        contentTextView.translatesAutoresizingMaskIntoConstraints = false
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imagePickerCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            imagePickerCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            imagePickerCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            imagePickerCollectionView.heightAnchor.constraint(equalToConstant: 100),
            
            titleTextField.topAnchor.constraint(equalTo: imagePickerCollectionView.bottomAnchor, constant: 16),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 44),
            
            contentTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 16),
            contentTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contentTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            contentTextView.heightAnchor.constraint(equalToConstant: 200),
            
            completeButton.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 32),
            completeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            completeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            completeButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func populateData() {
        guard let postDetail = postDetail else { return }
        
        titleTextField.text = postDetail.title
        contentTextView.text = postDetail.content
        originalImageURLs = postDetail.imageURLs
    }
    
    @objc private func handleCompleteButtonTapped() {
        guard let postDetail = postDetail else { return }

        let updatedTitle = titleTextField.text ?? ""
        let updatedContent = contentTextView.text ?? ""

        CommunityService.shared.updatePost(
            postID: postDetail.postID,
            userID: postDetail.userID,
            newTitle: updatedTitle,
            newContent: updatedContent,
            newImages: newImagesData,
            existingImageURLs: originalImageURLs,
            removedImageURLs: removedImageURLs
        ) { error in
            if let error = error {
                print("Failed to update post: \(error.localizedDescription)")
            } else {
                print("게시물 수정 완료")
              
                self.dismiss(animated: true)
            }
        }
    }

    @objc private func addImageButtonTapped() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 5
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true, completion: nil)
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                guard let self = self else { return }
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        // 피커에서 추가로 이미지 선택할 경우 이미지 배열에 추가해서 선택한 사진 바로 리로드
                        self.images.append(image)
                        self.imagePickerCollectionView.reloadData()
                        // 선택한 이미지 storage에 저장하기위해 data 형식으로 추출후 넘겨줌
                        if let imageData = image.jpegData(compressionQuality: 0.8) {
                            self.newImagesData.append(imageData)
                        }
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count + 1 // 전체 선택된 이미지 개수 + photopicker 이미지가 있어야 하므로 +1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagePickerCell", for: indexPath) as! ImagePickerCollectionViewCell
       // 첫번째는 무조건 사진 선택할수있는 셀
        if indexPath.item == 0 {
            cell.imageView.image = UIImage(systemName: "camera")
            cell.deleteButton.isHidden = true
        } else {
            // 그 다음에는 선택한 이미지 보여주는 셀
            cell.imageView.image = images[indexPath.item - 1]
            cell.deleteButton.isHidden = false
            cell.deleteButton.tag = indexPath.item - 1
            cell.deleteButton.addTarget(self, action: #selector(deleteImage(_:)), for: .touchUpInside)
        }
        return cell
    }
 
    @objc private func deleteImage(_ sender: UIButton) {
        let index = sender.tag
        if index < images.count {
            // 만약 삭제할 이미지가 기존의 이미지라면
            if index < originalImageURLs.count {
                let removedImageURL = originalImageURLs[index]
                removedImageURLs.append(removedImageURL) // 삭제해야될 url 들을 배열에 저장해서 관리
                originalImageURLs.remove(at: index) // 기존 이미지 URL에서 제거
            } else {
                // 새로운 이미지의 경우, newImagesData에서 제거 - 기존 이미지 뒤에 새로 선택한 사진이 나옴
                let newImageIndex = index - originalImageURLs.count
                newImagesData.remove(at: newImageIndex)
            }

            images.remove(at: index)
            imagePickerCollectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            addImageButtonTapped()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ImagePickerCollectionViewCell else { return }
        cell.deleteButton.removeTarget(nil, action: nil, for: .allEvents)
    }
}

//MARK: - CollectionView Cell
class ImagePickerCollectionViewCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8.0
        return imageView
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(deleteButton)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -10),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 10),
            deleteButton.widthAnchor.constraint(equalToConstant: 24),
            deleteButton.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        deleteButton.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
    }
    
    @objc private func handleDelete() {
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
