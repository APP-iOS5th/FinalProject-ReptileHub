//
//  AddPostView.swift
//  ReptileHub
//
//  Created by 조성빈 on 8/23/24.
//

import UIKit

class AddPostView: UIView {
    
    private var imagePickerCollectionView: UICollectionView = UICollectionView(frame: .zero)
    
    private let titleTextField: UITextField = UITextField()
    
    private let contentTextView: UITextView = UITextView()
    
    private let postButton: UIButton = UIButton()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
