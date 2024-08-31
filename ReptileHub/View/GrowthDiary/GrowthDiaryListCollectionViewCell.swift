//
//  GrowthDiaryListCollectionViewCell.swift
//  ReptileHub
//
//  Created by 이상민 on 8/13/24.
//

import UIKit
import SnapKit

class GrowthDiaryListCollectionViewCell: UICollectionViewCell {
    static let identifier = "GrowthDiaryListCell"
    
    private lazy var GrowthDiaryItemImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var GrowthDiaryItemTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.textFieldTitle
        return label
    }()
    
    private lazy var GrowthDiaryItemDate: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.textFieldPlaceholder
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
    
    private func setUp(){
        contentView.addSubview(GrowthDiaryItemImage)
        contentView.addSubview(GrowthDiaryItemTitle)
        contentView.addSubview(GrowthDiaryItemDate)
        
        GrowthDiaryItemImage.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(contentView)
            make.height.equalTo(GrowthDiaryItemImage.snp.width).multipliedBy(0.74)
        }
        
        GrowthDiaryItemTitle.snp.makeConstraints { make in
            make.top.equalTo(GrowthDiaryItemImage.snp.bottom).offset(10)
            make.leading.trailing.equalTo(contentView)
        }
        
        GrowthDiaryItemDate.snp.makeConstraints { make in
            make.leading.trailing.equalTo(contentView)
            make.top.equalTo(GrowthDiaryItemTitle.snp.bottom).offset(3)
            make.bottom.equalToSuperview()
        }
    }
    
    func configure(imageName: String, title: String, date: String){
        GrowthDiaryItemImage.setImage(with: imageName)
        GrowthDiaryItemTitle.text = title
        GrowthDiaryItemDate.text = "\(date) 생성"
    }
}
