//
//  ReplyListTableViewCell.swift
//  Reptile_Hub_UI
//
//  Created by 육현서 on 8/20/24.
//

import UIKit
import SnapKit

class ReplyListTableViewCell: UITableViewCell {
    
    private var commentDetail: UILabel = {
        let label = UILabel()
        label.text = "우왕"
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        return label
    }()
    
    private var commentDate: UILabel = {
        let label = UILabel()
        label.text = "2024.08.21. 03:03"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        return label
    }()
    
    private var postTitle: UILabel = {
        let label = UILabel()
        label.text = "먉옹 먀아아옭 므야얅옭"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()
    
    private var commentCount: UILabel = {
        let label = UILabel()
        label.text = "99"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.backgroundColor = UIColor(red: 226/255.0, green: 226/255.0, blue: 226/255.0, alpha: 1)
        label.textColor = .gray
        label.textAlignment = .center
        
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 10
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [postTitle, commentCount])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 15
        stackView.distribution = .fill
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(commentDetail)
        contentView.addSubview(commentDate)
        contentView.addSubview(stackView)
        
        commentDetail.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        commentDate.snp.makeConstraints { make in
            make.top.equalTo(commentDetail.snp.bottom).offset(4)
            make.leading.equalTo(commentDetail)
        }
        
        commentCount.snp.makeConstraints { make in
            make.width.equalTo(30)
            make.height.equalTo(22)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(commentDate.snp.bottom).offset(4)
            make.leading.equalTo(commentDetail)
//            make.trailing.equalTo(commentDetail)
            make.width.greaterThanOrEqualTo(80)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
