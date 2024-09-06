//
//  WriteReplyListTableViewCell.swift
//  Reptile_Hub_UI
//
//  Created by 육현서 on 8/20/24.
//

import UIKit
import SnapKit

class WriteReplyListTableViewCell: UITableViewCell {
    
    private var commentDetail: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        return label
    }()
    
    private var commentDate: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        return label
    }()
    
    private var postTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()
    
    private var commentCount: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.backgroundColor = .groupProfileBG
        label.textColor = .imagePickerPlaceholder
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
            make.width.greaterThanOrEqualTo(80)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    func setCommentData(commentData: CommentResponse, postData: PostDetailResponse) {
        commentDetail.text = commentData.content
        
        // TODO: - 게시글 타이틀, 게시글의 총 댓글 개수로 수정 
        commentCount.text = String(postData.commentCount)
        postTitle.text = postData.title

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm" // 원하는 포맷으로 설정
        commentDate.text = dateFormatter.string(for: commentData.createdAt)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
