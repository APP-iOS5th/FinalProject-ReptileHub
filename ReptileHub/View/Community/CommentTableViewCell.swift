//
//  CommentTableViewCell.swift
//  ReptileHub
//
//  Created by 조성빈 on 8/18/24.
//

import UIKit

protocol CommentTableViewCellDelegate: AnyObject {
    func deleteCommentAction(cell: CommentTableViewCell)
    
    func blockCommentAction(cell: CommentTableViewCell)
    
    func reportCommentAction(cell: CommentTableViewCell)
    
    func onTapCommentProfile(cell: CommentTableViewCell)
}

class CommentTableViewCell: UITableViewCell {
    
    weak var delegate: CommentTableViewCellDelegate?
    
    // 상단 게시글 정보
    private let profileImage: UIImageView = UIImageView()
    
    let nameLabel: UILabel = UILabel()
    let commentLabel: UILabel = UILabel()
    let timestampLabel: UILabel = UILabel()
    let elementStackView: UIStackView = UIStackView()
    
    private var menuButton: UIButton = UIButton()
    private var myMenu: [UIAction] = []
    private var otherMenu: [UIAction] = []
    

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        setupProfileImage()
        setupMenuButton()
        setupElementStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    //MARK: - 프로필 이미지
    private func setupProfileImage() {
//        profileImage.image = UIImage(systemName: "person")
        profileImage.backgroundColor = .lightGray
        profileImage.layer.cornerRadius = 20
        profileImage.clipsToBounds = true
        
        profileImage.isUserInteractionEnabled = true
        let profileTapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapProfile))
        profileImage.addGestureRecognizer(profileTapGesture)

        self.contentView.addSubview(profileImage)
        
        profileImage.snp.makeConstraints { make in
            make.height.width.equalTo(40)
            make.top.equalTo(self.contentView.snp.top).offset(5)
            make.leading.equalTo(self.contentView.snp.leading).offset(2)
        }
    }
    
    @objc private func onTapProfile() {
        delegate?.onTapCommentProfile(cell: self)
    }
        
    
    //MARK: - 제목, 닉네임, 시간 StackView(elementStackView)
    private func setupElementStackView() {
        nameLabel.text = "부천 정구현"
        nameLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        nameLabel.textColor = .black
        nameLabel.sizeToFit()

        commentLabel.text = "테스트 내용"
        commentLabel.numberOfLines = 0
        commentLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        commentLabel.textColor = .black
        timestampLabel.text = "24.08.09 17:31"
        timestampLabel.font = UIFont.systemFont(ofSize: 10, weight: .light)
        timestampLabel.textColor = UIColor.lightGray

        elementStackView.axis = .vertical
        elementStackView.distribution = .fill
        elementStackView.alignment = .firstBaseline
        elementStackView.spacing = 0

        elementStackView.addArrangedSubview(nameLabel)
        elementStackView.addArrangedSubview(commentLabel)
        elementStackView.addArrangedSubview(timestampLabel)
        
        self.contentView.addSubview(elementStackView)

        elementStackView.snp.makeConstraints { make in
            make.top.equalTo(self.contentView.snp.top).offset(5)
            make.leading.equalTo(profileImage.snp.trailing).offset(10)
            make.trailing.equalTo(menuButton.snp.leading).offset(0)
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-5)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(elementStackView.snp.top)
            make.leading.equalTo(elementStackView.snp.leading)
            make.height.equalTo(15)
        }
        timestampLabel.snp.makeConstraints { make in
            make.leading.equalTo(elementStackView.snp.leading)
            make.bottom.equalTo(elementStackView.snp.bottom)
            make.height.equalTo(13)
        }
        commentLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom)
            make.leading.equalTo(elementStackView.snp.leading)
            make.bottom.equalTo(timestampLabel.snp.top)
            make.height.equalTo(30).priority(250)
        }
    }
    
    
    //MARK: - menu 버튼
    private func setupMenuButton() {
        let ellipsisImage = UIImage(systemName: "ellipsis")
            
        // UIButton을 생성하여 회전
        menuButton = UIButton(type: .system)
        menuButton.setImage(ellipsisImage, for: .normal)
        menuButton.tintColor = .gray
        menuButton.transform = CGAffineTransform(rotationAngle: .pi / 2) // 90도 회전
        
        myMenu = [ UIAction(title: "삭제하기", image: UIImage(systemName: "trash"),attributes: .destructive,handler: { _ in self.deleteCommentAction() }) ]
        otherMenu = [ UIAction(title: "작성자 차단하기", image: UIImage(systemName: "hand.raised"), handler: { _ in
            self.blockCommentAction()
        }),
        UIAction(title: "신고하기", image: UIImage(systemName: "exclamationmark.bubble"), attributes: .destructive, handler: { _ in
            self.reportCommentAction()
        }) ]
        
        menuButton.showsMenuAsPrimaryAction = true
        
        self.contentView.addSubview(menuButton)
        
        menuButton.snp.makeConstraints { make in
            make.top.equalTo(self.contentView.snp.top).offset(10)
            make.trailing.equalTo(self.contentView.snp.trailing)
        }
    }
    
    private func copyCommentAction() {
        print("댓글 복사하기 클릭.")
    }
    
    private func deleteCommentAction() {
        print("댓글 삭제하기 클릭.")
        self.delegate?.deleteCommentAction(cell: self)
    }
    
    private func blockCommentAction() {
        print("댓글 작성자 차단하기 클릭.")
        self.delegate?.blockCommentAction(cell: self)
    }
    
    private func reportCommentAction() {
        print("댓글 작성자 신고하기 클릭.")
        self.delegate?.reportCommentAction(cell: self)
    }

    //MARK: - configure cell
    func configureCell(profileURL: String, name: String, content: String, createAt: String, commentUserId: String) {
        profileImage.setImage(with: profileURL)
        nameLabel.text = name
        commentLabel.text = content
        timestampLabel.text = createAt
        
        let isMine: Bool = commentUserId == UserService.shared.currentUserId
        
        menuButton.menu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: isMine ? myMenu : otherMenu)

    }

}
