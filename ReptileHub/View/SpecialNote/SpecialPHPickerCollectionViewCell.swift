//
//  SpecialPHPickerCollectionViewCell.swift
//  ReptileHub
//
//  Created by 황민경 on 8/30/24.
//

import UIKit
import SnapKit

protocol SpecialPHPickerCollectionViewCellDelegate: AnyObject {
    // 셀 삭제 버튼
    func didTapDeleteButton(indexPath: IndexPath)
    
}

class SpecialPHPickerCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: SpecialPHPickerCollectionViewCellDelegate?
    
    lazy var imageView: UIImageView = UIImageView()
    
    lazy var deleteButton: UIButton = UIButton(type: .custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 셀 재사용시 deleteButton 사라짐 방지
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        deleteButton.isHidden = false
        delegate = nil
    }
    
    //MARK: - setup Cell
    private func configureCell() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .imagePicker
        
        deleteButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        
        
        self.contentView.addSubview(imageView)
        self.contentView.addSubview(deleteButton)
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(self.contentView).offset(10)
            make.leading.equalTo(self.contentView.snp.leading)
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-20)
            make.bottom.equalTo(self.contentView).offset(-10)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(self.contentView.snp.top)
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-10)
            make.width.height.equalTo(30)
        }
        
    }
    
    @objc
    private func deleteAction() {
        if let collectionView = superview as? UICollectionView {
            if let indexPath = collectionView.indexPath(for: self) {
                delegate?.didTapDeleteButton(indexPath: indexPath)
            }
        }

    }
}
