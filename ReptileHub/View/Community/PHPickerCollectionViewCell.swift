//
//  PHPickerCollectionViewCell.swift
//  ReptileHub
//
//  Created by 조성빈 on 8/28/24.
//

import UIKit
import SnapKit

class PHPickerCollectionViewCell: UICollectionViewCell {
    
    var imageView: UIImageView = UIImageView()
    
    let deleteButton: UIButton = UIButton(type: .custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .red
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - setup Cell
    private func configureCell() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .yellow
        imageView.tintColor = .green
        
        deleteButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        
        
        self.contentView.addSubview(imageView)
        self.contentView.addSubview(deleteButton)
        
        imageView.snp.makeConstraints { make in
            make.top.leading.equalTo(self.contentView).offset(10)
            make.trailing.bottom.equalTo(self.contentView).offset(-10)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(self.contentView.snp.top)
            make.trailing.equalTo(self.contentView.snp.trailing)
            make.width.height.equalTo(30)
        }
        
    }
    
    @objc
    private func deleteAction() {
        print("이미지 셀 삭제 클릭.")
    }
}
