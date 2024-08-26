//
//  AddPostView.swift
//  ReptileHub
//
//  Created by 조성빈 on 8/23/24.
//

import UIKit
import SnapKit

class AddPostView: UIView {
    
    private var imagePickerCollectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    private let titleTextField: UITextField = UITextField()
    
    private let contentTextView: UITextView = UITextView()
    
    private let postButton: UIButton = UIButton()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        setupImagePickerCollectionView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    //MARK: - 이미지피커 콜렉션뷰 setup
    private func setupImagePickerCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.itemSize = CGSize(width: 80, height: 80)
        
        imagePickerCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        imagePickerCollectionView.backgroundColor = .lightGray
        imagePickerCollectionView.register(ImagePickerCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        self.addSubview(imagePickerCollectionView)
        
        imagePickerCollectionView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.equalTo(self.snp.leading).offset(24)
            make.trailing.equalTo(self.snp.trailing).offset(-24)
            make.height.equalTo(80)
        }
    }
    
    //MARK: - title Textfield setup
    private func setupTitleTextView() {
        
    }
    
}

