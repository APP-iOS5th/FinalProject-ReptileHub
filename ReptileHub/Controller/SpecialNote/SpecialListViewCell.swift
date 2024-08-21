//
//  SpecialListViewCell.swift
//  ReptileHub
//
//  Created by 황민경 on 8/21/24.
//

import UIKit
import SnapKit

class SpecialListViewCell: UITableViewCell {
    
    static let identifier = "SpecialCell"
    
    private lazy var cellView: UIView = {
        let cellView = UIView()
        cellView.backgroundColor = UIColor(named: "Light_Gray")
        cellView.layer.cornerRadius = 5
        return cellView
    }()
    
    private lazy var specialImageView: UIImageView = {
        let specialImageView = UIImageView()
        specialImageView.image = UIImage(named: "Snowball")
        specialImageView.layer.cornerRadius = 5
        specialImageView.contentMode = .scaleAspectFill
        return specialImageView
    }()
    
    private lazy var specialTitle: UILabel = {
        let specialTitle = UILabel()
        specialTitle.text = "일지 제목"
        specialTitle.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        specialTitle.textColor = .black
        return specialTitle
    }()
    
    private lazy var specialText: UILabel = {
        let specialText = UILabel()
        specialText.text = "동해물과 백두산이 마르고 닳도록 하느님이 보우하사 우리나라 만세 가나다라마사아자차카타파하"
        specialText.numberOfLines = 2
//        specialText.lineBreakStrategy = .hangulWordPriority
        specialText.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        specialText.textColor = UIColor(named: "Dark_Gray")
        return specialText
    }()
    
    private lazy var dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.text = "24.08.05"
        dateLabel.font = UIFont.systemFont(ofSize: 12, weight: .light)
        dateLabel.textColor = .lightGray
        return dateLabel
    }()
    
    private lazy var deleteButton: UIButton = {
        let deleteButton = UIButton()
        deleteButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        deleteButton.tintColor = .darkGray
        return deleteButton
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI2()
    }
    
    private func setupUI2() {
        contentView.addSubview(cellView)
        contentView.addSubview(specialImageView)
        contentView.addSubview(specialTitle)
        contentView.addSubview(specialText)
        contentView.addSubview(dateLabel)
        contentView.addSubview(deleteButton)
        
//        cellView.snp.makeConstraints{(make) in
//            make.centerX.equalTo(safeAreaLayoutGuide)
//            make.width.equalTo(safeAreaLayoutGuide).offset(-30)
//            make.height.equalTo(100)
//        }
        specialImageView.snp.makeConstraints{(make) in
            make.width.height.equalTo(100)
            make.leading.equalTo(contentView)
            make.centerY.equalTo(contentView)
        }
        specialTitle.snp.makeConstraints{(make) in
            make.leading.equalTo(specialImageView.snp.trailing).offset(10)
            make.trailing.equalTo(deleteButton.snp.leading).offset(2)
            make.top.equalTo(contentView).offset(10)
        }
        specialText.snp.makeConstraints{(make) in
            make.leading.equalTo(specialImageView.snp.trailing).offset(10)
            make.trailing.equalTo(deleteButton.snp.leading).offset(2)
            make.top.equalTo(specialTitle.snp.bottom).offset(5)
//            make.bottomMargin.equalTo(dateLabel.snp.top).offset(5)
        }
        dateLabel.snp.makeConstraints{(make) in
            make.leading.equalTo(specialImageView.snp.trailing).offset(10)
            make.bottom.equalTo(contentView).offset(-5)
        }
        deleteButton.snp.makeConstraints{(make) in
            make.trailing.equalTo(contentView).offset(-15)
            make.top.equalTo(contentView).offset(10)
        }
        contentView.layer.cornerRadius = 5
//        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = UIColor(named: "Light_Gray")
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 15, bottom: 10, right: 15))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
