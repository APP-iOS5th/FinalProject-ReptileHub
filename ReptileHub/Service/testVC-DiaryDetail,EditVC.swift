//
//  testVC-DiaryDetail,EditVC.swift
//  ReptileHub
//
//  Created by 임재현 on 8/28/24.
//

import Foundation
import UIKit
import PhotosUI

class DiaryDetailViewController: UIViewController {
    
    var diaryEntry: DiaryResponse?
    var diaryID: String?
    var userID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        fetchDiaryEntryDetails()
    }
    
    private func setupUI() {
        let editButton = UIButton(type: .system)
        editButton.setTitle("수정하기", for: .normal)
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(editButton)
        
        NSLayoutConstraint.activate([
            editButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            editButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            editButton.widthAnchor.constraint(equalToConstant: 100),
            editButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func fetchDiaryEntryDetails() {
        let userID = "XYmrUBcFhjdYZSM8TFihX0QNN7O2"
        let diaryID = "A3D2C194-D10E-40B2-B75B-E3F686803328"
        
        
        
        DiaryPostService.shared.fetchDiaryEntries(userID: userID, diaryID: diaryID) { [weak self] result in
            switch result {
            case .success(let diaryEntries):
                guard let self = self, let diaryEntry = diaryEntries.first else { return }
                self.diaryEntry = diaryEntry
                print("diaryEntry - \(diaryEntry)")
                // 여기에 UI 업데이트를 추가할 수 있습니다.
            case .failure(let error):
                print("Failed to fetch diary entry: \(error.localizedDescription)")
            }
        }
    }
    
    @objc private func editButtonTapped() {
        guard let diaryEntry = diaryEntry else { return }
        
        downloadImages(from: diaryEntry.imageURLs) { images in
            DispatchQueue.main.async {
                let editVC = DiaryEditViewController()
                editVC.diaryEntry = diaryEntry
                editVC.images = images.compactMap { $0 }
                editVC.originalImageURLs = diaryEntry.imageURLs
                editVC.modalPresentationStyle = .fullScreen
                self.present(editVC, animated: true)
            }
        }
    }
    
    private func downloadImages(from urls: [String], completion: @escaping ([UIImage?]) -> Void) {
        var images = [UIImage?](repeating: nil, count: urls.count)
        let dispatchGroup = DispatchGroup()
        
        for (index, urlString) in urls.enumerated() {
            guard let url = URL(string: urlString) else { continue }
            
            dispatchGroup.enter()
            URLSession.shared.dataTask(with: url) { data, _, error in
                defer { dispatchGroup.leave() }
                
                if let data = data, let image = UIImage(data: data) {
                    images[index] = image
                } else {
                    print("Failed to download image from \(urlString): \(error?.localizedDescription ?? "No error information")")
                }
            }.resume()
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(images)
        }
    }
}


import UIKit
import PhotosUI

class DiaryEditViewController: UIViewController, PHPickerViewControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var diaryEntry: DiaryResponse?
    var originalImageURLs: [String] = []
    var images: [UIImage?] = []
    var newImagesData: [Data] = []
    var removedImageURLs: [String] = []
    
    private var imagePickerCollectionView: UICollectionView!
    private let titleTextField = UITextField()
    private let contentTextView = UITextView()
    private let completeButton = UIButton(type: .system)
    
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
        
        titleTextField.placeholder = "제목을 입력해주세요."
        titleTextField.borderStyle = .roundedRect
        
        contentTextView.layer.borderColor = UIColor.lightGray.cgColor
        contentTextView.layer.borderWidth = 1.0
        contentTextView.layer.cornerRadius = 8.0
        
        completeButton.setTitle("수정완료", for: .normal)
        completeButton.backgroundColor = UIColor.systemGreen
        completeButton.setTitleColor(.white, for: .normal)
        completeButton.layer.cornerRadius = 8.0
        completeButton.addTarget(self, action: #selector(handleCompleteButtonTapped), for: .touchUpInside)
        
        view.addSubview(imagePickerCollectionView)
        view.addSubview(titleTextField)
        view.addSubview(contentTextView)
        view.addSubview(completeButton)
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
        guard let diaryEntry = diaryEntry else { return }
        
        titleTextField.text = diaryEntry.title
        contentTextView.text = diaryEntry.content
        originalImageURLs = diaryEntry.imageURLs
    }
    
    @objc private func handleCompleteButtonTapped() {
        let userID = "XYmrUBcFhjdYZSM8TFihX0QNN7O2"
        let diaryID = "A3D2C194-D10E-40B2-B75B-E3F686803328"
        let entryID = "34CA217A-BE59-449C-A17A-FE5EB5108FA5"
        
        let updatedTitle = titleTextField.text ?? ""
        let updatedContent = contentTextView.text ?? ""
        
//        DiaryPostService.shared.updateDiary(
//            userID: userID,
//            diaryID: diaryID,
//            entryID: entryID,
//            newTitle: updatedTitle,
//            newContent: updatedContent,
//            newImages: newImagesData, // 새로 추가된 이미지 데이터를 전달
//            existingImageURLs: originalImageURLs, // 기존 이미지 URL 배열을 전달
//            removedImageURLs: removedImageURLs // 삭제된 이미지 URL 배열을 전달
//        ) { error in
//            if let error = error {
//                print("Failed to update diary entry: \(error.localizedDescription)")
//            } else {
//                print("Diary entry updated successfully")
//                self.dismiss(animated: true) // 또는 navigation pop
//            }
//        }
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
                guard let self = self, let image = object as? UIImage, let imageData = image.jpegData(compressionQuality: 0.8) else { return }
                
                DispatchQueue.main.async {
                    self.images.append(image)
                    self.newImagesData.append(imageData)
                    self.imagePickerCollectionView.reloadData()
                    
                }
                
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagePickerCell", for: indexPath) as! ImagePickerCollectionViewCell
        if indexPath.item == 0 {
            cell.imageView.image = UIImage(systemName: "camera")
            cell.deleteButton.isHidden = true
        } else {
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
                removedImageURLs.append(removedImageURL)
                originalImageURLs.remove(at: index) // 기존 이미지 URL에서 제거
            } else {
                // 새로운 이미지의 경우, newImagesData에서 제거
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

