//
//  testVC - GrowthDiaryEditViewController.swift
//  ReptileHub
//
//  Created by 임재현 on 8/28/24.
//

import Foundation
import UIKit
import PhotosUI

class GrowthDiaryEditViewController: UIViewController, PHPickerViewControllerDelegate {
    
    // UI 요소들
    private let selfImageView = UIImageView()
    private let selfNameTextField = UITextField()
    
    private let motherImageView = UIImageView()
    private let motherNameTextField = UITextField()
    private let fatherNameTextField = UITextField()
    private let fatherImageView = UIImageView()
    private let updateButton = UIButton(type: .system)
    
    // 현재의 다이어리 데이터를 저장하는 변수
    var growthDiary: GrowthDiaryRequest?
    var userID: String?
    var diaryID: String?
    
    private var newSelfImageData: Data?
    private var newMotherImageData: Data?
    private var newFatherImageData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        fetchGrowthDiaryDetails() // 데이터 가져오기
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // 이미지 뷰 기본 설정
        [selfImageView, motherImageView, fatherImageView].forEach { imageView in
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.borderColor = UIColor.lightGray.cgColor
            imageView.layer.borderWidth = 1.0
            imageView.layer.cornerRadius = 8.0
            imageView.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
            imageView.addGestureRecognizer(tapGesture)
            view.addSubview(imageView)
        }
        
        // 텍스트 필드 기본 설정
        [selfNameTextField, motherNameTextField, fatherNameTextField].forEach { textField in
            textField.borderStyle = .roundedRect
            view.addSubview(textField)
        }
        
        // 버튼 설정
        updateButton.setTitle("Update", for: .normal)
        updateButton.addTarget(self, action: #selector(updateButtonTapped), for: .touchUpInside)
        view.addSubview(updateButton)
    }
    
    private func setupConstraints() {
        [selfImageView, motherImageView, fatherImageView, selfNameTextField, motherNameTextField, fatherNameTextField, updateButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            // Self Image & Name
            selfImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            selfImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            selfImageView.widthAnchor.constraint(equalToConstant: 100),
            selfImageView.heightAnchor.constraint(equalToConstant: 100),
            
            selfNameTextField.topAnchor.constraint(equalTo: selfImageView.bottomAnchor, constant: 8),
            selfNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            selfNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Mother Image & Name
            motherImageView.topAnchor.constraint(equalTo: selfNameTextField.bottomAnchor, constant: 16),
            motherImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            motherImageView.widthAnchor.constraint(equalToConstant: 100),
            motherImageView.heightAnchor.constraint(equalToConstant: 100),
            
            motherNameTextField.topAnchor.constraint(equalTo: motherImageView.bottomAnchor, constant: 8),
            motherNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            motherNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Father Image & Name
            fatherImageView.topAnchor.constraint(equalTo: motherNameTextField.bottomAnchor, constant: 16),
            fatherImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            fatherImageView.widthAnchor.constraint(equalToConstant: 100),
            fatherImageView.heightAnchor.constraint(equalToConstant: 100),
            
            fatherNameTextField.topAnchor.constraint(equalTo: fatherImageView.bottomAnchor, constant: 8),
            fatherNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            fatherNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Update Button
            updateButton.topAnchor.constraint(equalTo: fatherNameTextField.bottomAnchor, constant: 32),
            updateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            updateButton.widthAnchor.constraint(equalToConstant: 100),
            updateButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func fetchGrowthDiaryDetails() {
        // TODO: 이 부분 주석 안하면 실행 안됌..
        let userID = "XYmrUBcFhjdYZSM8TFihX0QNN7O2"
        let diaryID = "4258CA71-F227-4F28-955F-A79952B33671"
        DiaryPostService.shared.fetchGrowthDiaryDetails(userID: userID, diaryID: diaryID) { [weak self] diaryResponse in
            switch diaryResponse{
            case .success(_):
                print("성공")
            case .failure(_):
                print("실패")
            }
        }
    }
    
    private func populateData(with diaryResponse: GrowthDiaryResponse) {
        // 텍스트 필드에 기본 정보 할당
        selfNameTextField.text = diaryResponse.lizardInfo.name
        motherNameTextField.text = diaryResponse.parentInfo?.mother.name
        fatherNameTextField.text = diaryResponse.parentInfo?.father.name
        
        // 이미지 로드
        loadImage(from: diaryResponse.lizardInfo.imageURL, into: selfImageView)
        loadImage(from: diaryResponse.parentInfo?.mother.imageURL, into: motherImageView)
        loadImage(from: diaryResponse.parentInfo?.father.imageURL, into: fatherImageView)
        
        // Response 데이터를 Request 데이터로 변환

        let lizardInfo = LizardInfo(
            name: diaryResponse.lizardInfo.name,
            species: diaryResponse.lizardInfo.species,
            morph: diaryResponse.lizardInfo.morph,
            hatchDays: diaryResponse.lizardInfo.hatchDays,
            gender: Gender(rawValue: diaryResponse.lizardInfo.gender) ?? .unKnown,
            weight: diaryResponse.lizardInfo.weight,
            feedMethod: diaryResponse.lizardInfo.feedMethod,
            tailexistence: diaryResponse.lizardInfo.tailexistence,
            imageURL: diaryResponse.lizardInfo.imageURL
        )
        
        let parentInfo = Parents(
            mother: ParentInfo(
                name: diaryResponse.parentInfo?.mother.name ?? "",
                morph: diaryResponse.parentInfo?.mother.morph,
                imageURL: diaryResponse.parentInfo?.mother.imageURL
            ),
            father: ParentInfo(
                name: diaryResponse.parentInfo?.father.name ?? "",
                morph: diaryResponse.parentInfo?.father.morph,
                imageURL: diaryResponse.parentInfo?.father.imageURL
            )
        )
        
        // GrowthDiaryRequest 생성
        self.growthDiary = GrowthDiaryRequest(lizardInfo: lizardInfo, parentInfo: parentInfo)
    }
    
    private func loadImage(from urlString: String?, into imageView: UIImageView) {
        guard let urlString = urlString, let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                imageView.image = image
            }
        }.resume()
    }
    
    @objc private func imageTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedImageView = sender.view as? UIImageView else { return }
        
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        
        switch tappedImageView {
        case selfImageView:
            picker.accessibilityHint = "self"
        case motherImageView:
            picker.accessibilityHint = "mother"
        case fatherImageView:
            picker.accessibilityHint = "father"
        default:
            return
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    @objc private func updateButtonTapped() {
        guard var growthDiary = growthDiary else { return }
        let userID = "XYmrUBcFhjdYZSM8TFihX0QNN7O2"
        let diaryID = "4258CA71-F227-4F28-955F-A79952B33671"
        // 이름 업데이트
        growthDiary.lizardInfo.name = selfNameTextField.text ?? ""
        growthDiary.parentInfo?.mother.name = motherNameTextField.text ?? ""
        growthDiary.parentInfo?.father.name = fatherNameTextField.text ?? ""
        
        // 다이어리 업데이트 함수 호출
        DiaryPostService.shared.updateGrowthDiary(
            userID: userID,
            diaryID: diaryID,
            updatedDiary: growthDiary,
            newSelfImageData: newSelfImageData,
            newMotherImageData: newMotherImageData,
            newFatherImageData: newFatherImageData
        ) { error in
            if let error = error {
                print("Failed to update growth diary: \(error.localizedDescription)")
            } else {
                print("Growth diary updated successfully")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // PHPickerViewControllerDelegate
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true, completion: nil)
        
        guard let result = results.first, let hint = picker.accessibilityHint else { return }
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            guard let self = self, let image = object as? UIImage, let imageData = image.jpegData(compressionQuality: 0.8) else { return }
            
            DispatchQueue.main.async {
                switch hint {
                case "self":
                    self.newSelfImageData = imageData
                    self.selfImageView.image = image
                case "mother":
                    self.newMotherImageData = imageData
                    self.motherImageView.image = image
                case "father":
                    self.newFatherImageData = imageData
                    self.fatherImageView.image = image
                default:
                    break
                }
            }
        }
    }
}

