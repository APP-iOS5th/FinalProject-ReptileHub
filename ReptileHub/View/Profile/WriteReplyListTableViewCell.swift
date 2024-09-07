//
//  WriteReplyListTableViewCell.swift
//  Reptile_Hub_UI
//
//  Created by 육현서 on 8/20/24.
//

import UIKit
import SnapKit

protocol WriteReplyListTableViewCellDelegate: AnyObject {
    func deleteComment(cell: WriteReplyListTableViewCell)
}

class WriteReplyListTableViewCell: UITableViewCell {
    
    weak var delegate: WriteReplyListTableViewCellDelegate?
    
    // MARK: - 댓글 테이블 뷰 셀 구성요소
    // 댓글 내용
    private var commentDetail: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        return label
    }()
    
    // 댓글 단 날짜
    private var commentDate: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        return label
    }()
    
    // 댓글 단 게시글 제목
    private var postTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()
    
    // 댓글 삭제 버튼
    private var commentDeleteButton: UIButton = {
        let button = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .light)
        let image = UIImage(systemName: "xmark", withConfiguration: imageConfig)
                
        button.backgroundColor = .white
        button.layer.cornerRadius = CGFloat(12.5)
        button.setImage(image, for: .normal)
        button.tintColor = .textFieldPlaceholder
        button.addTarget(self, action: #selector(commentDelete), for: .touchUpInside)
        return button
    }()
    
    // 댓글 단 게시글의 총 댓글 수
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
    
    // 게시글 제목 + 총 댓글 수 스택뷰
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
        contentView.addSubview(commentDeleteButton)
        
        commentDetail.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        commentDate.snp.makeConstraints { make in
            make.top.equalTo(commentDetail.snp.bottom).offset(4)
            make.leading.equalTo(commentDetail)
        }
        
        commentDeleteButton.snp.makeConstraints { make in
            make.width.height.equalTo(25)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-20)
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
    
    // MARK: - 댓글 데이터
    func setCommentData(commentData: CommentResponse, postData: PostDetailResponse) {
        commentDetail.text = commentData.content
        commentCount.text = String(postData.commentCount)
        postTitle.text = postData.title

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        commentDate.text = dateFormatter.string(for: commentData.createdAt)
    }
    
    @objc func commentDelete() {
        self.delegate?.deleteComment(cell: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
