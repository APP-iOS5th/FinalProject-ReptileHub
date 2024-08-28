//
//  AddPostView.swift
//  ReptileHub
//
//  Created by 조성빈 on 8/23/24.
//

import UIKit
import SnapKit
import PhotosUI

class AddPostView: UIView {
    
    // PhPicker에서 선택한 이미지들
    var selectedImages: [UIImage?] = []
    
    
    // 키보드 탭 제스쳐
    lazy var tapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        tap.cancelsTouchesInView = false // 터치 이벤트를 취소하지 않도록 설정
        return tap
    }()
    
    var imagePickerCollectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    private let titleTextField: UITextField = UITextField()
    
    private let contentTextView: UITextView = UITextView()
    
    private let postButton: UIButton = UIButton(type: .system)
    
    var picker: PHPickerViewController = PHPickerViewController(configuration: PHPickerConfiguration())
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        // 제스처 적용(슈퍼뷰 클릭시 키보드 내려감)
        self.addGestureRecognizer(tapGesture)
        
        setupImagePickerCollectionView()
        setupTitleTextView()
        setupContentTextView()
        setupPostButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // super view 클릭시 키보드 내려감
    @objc
    func tapHandler(_ sender: UIView) {
        titleTextField.resignFirstResponder()
        contentTextView.resignFirstResponder()
    }
    
    //MARK: - 이미지피커 콜렉션뷰 setup
    private func setupImagePickerCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: 90, height: 90)
        
        imagePickerCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        imagePickerCollectionView.backgroundColor = .lightGray
        imagePickerCollectionView.register(PHPickerCollectionViewCell.self, forCellWithReuseIdentifier: "PHPickerCell")
        
        self.addSubview(imagePickerCollectionView)
        
        imagePickerCollectionView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.equalTo(self.snp.leading).offset(24)
            make.trailing.equalTo(self.snp.trailing).offset(-24)
            make.height.equalTo(90)
        }
    }
    
    //MARK: - title Textfield setup
    private func setupTitleTextView() {
        titleTextField.placeholder = "제목을 입력해주세요"
        titleTextField.borderStyle = .roundedRect
        
        self.addSubview(titleTextField)
        
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(imagePickerCollectionView.snp.bottom).offset(15)
            make.leading.equalTo(imagePickerCollectionView.snp.leading)
            make.trailing.equalTo(imagePickerCollectionView.snp.trailing)
            make.height.equalTo(40)
        }
    }
    
    
    //MARK: - content TextView setup
    private func setupContentTextView() {
        contentTextView.layer.borderColor = UIColor.lightGray.cgColor
        contentTextView.layer.borderWidth = 1.0
        contentTextView.layer.cornerRadius = 10
        
        self.addSubview(contentTextView)
        
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(15)
            make.leading.equalTo(titleTextField.snp.leading)
            make.trailing.equalTo(titleTextField.snp.trailing)
            make.height.greaterThanOrEqualTo(200)
        }
        
    }
    
    
    //MARK: - postButton setup
    private func setupPostButton() {
        postButton.setTitle("등록하기", for: .normal)
        postButton.backgroundColor = .addBtnGraphTabbar
        postButton.setTitleColor(.white, for: .normal)
        postButton.layer.cornerRadius = 10
        
        self.addSubview(postButton)
        
        postButton.snp.makeConstraints { make in
            make.top.equalTo(contentTextView.snp.bottom).offset(15)
            make.leading.equalTo(contentTextView.snp.leading)
            make.trailing.equalTo(contentTextView.snp.trailing)
            make.height.equalTo(45)
        }
    }
    
    func configureAddPostView(delegate: UICollectionViewDelegate, datasource: UICollectionViewDataSource) {
        imagePickerCollectionView.delegate = delegate
        imagePickerCollectionView.dataSource = datasource
    }
    
    func createPHPickerVC() -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0
        config.filter = .images
        
        return PHPickerViewController(configuration: config)
        
    }
    
}

