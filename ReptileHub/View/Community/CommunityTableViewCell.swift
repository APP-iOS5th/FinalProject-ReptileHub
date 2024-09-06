//
//  CommunityTableViewCell.swift
//  ReptileHub
//
//  Created by 조성빈 on 8/8/24.
//

import UIKit
import SnapKit
import Kingfisher

let imageCache = NSCache<NSString, UIImage>()

//protocol CommunityTableViewCellDelegate: AnyObject {
//    func deleteAlert(cell: CommunityTableViewCell)
//    
//    func blockAlert(cell: CommunityTableViewCell)
//}

class CommunityTableViewCell: UITableViewCell {
    
//    weak var delegate: CommunityTableViewCellDelegate?
    

    lazy var thumbnailImageView: UIImageView = UIImageView()
    
    lazy var titleLabel: UILabel = UILabel()
    private let contentLabel: UILabel = UILabel()
    private let mainInfoStackView: UIStackView = UIStackView()
    
    private let commentIcon: UIImageView = UIImageView()
    private let commentCountLabel: UILabel = UILabel()
    private let bookmarkIcon: UIImageView = UIImageView()
    private let bookmarkCountLabel: UILabel = UILabel()
    private let firstStackView: UIStackView = UIStackView()
    
    private let nicknameLabel: UILabel = UILabel()
    private let timestampLabel: UILabel = UILabel()
    private let secondStackView: UIStackView = UIStackView()
    
//    private let menuButton: UIButton = UIButton()
//    private var myMenu: [UIAction] = []
//    private var otherMenu: [UIAction] = []
    


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupThumbnail()
//        setupMenuButton()
        setupMainInfoStackView()
        setupSubInfoStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        thumbnailImageView.image = nil
        titleLabel.text = ""
        contentLabel.text = ""
        commentCountLabel.text = ""
        bookmarkCountLabel.text = ""
        nicknameLabel.text = ""
        timestampLabel.text = ""
    }
    
    
    //MARK: - Thumnail Image
    private func setupThumbnail() {
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.layer.cornerRadius = 5
        thumbnailImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        thumbnailImageView.backgroundColor = .textFieldPlaceholder.withAlphaComponent(0.3)
        
        self.contentView.addSubview(thumbnailImageView)
        
        thumbnailImageView.snp.makeConstraints { make in
            make.height.width.equalTo(85)
            make.centerY.equalToSuperview()

            make.leading.equalTo(self.contentView.snp.leading).offset(12)
        }
    }
    
    //MARK: - 제목, 내용 StackView
    private func setupMainInfoStackView() {
        mainInfoStackView.axis = .vertical
        mainInfoStackView.distribution = .fill
        mainInfoStackView.alignment = .leading
        
        titleLabel.text = "Title"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        contentLabel.text = "Content"
        contentLabel.numberOfLines = 0
        contentLabel.font = UIFont.systemFont(ofSize: 15, weight: .light)
        
        self.contentView.addSubview(mainInfoStackView)
        
        mainInfoStackView.snp.makeConstraints { make in
            make.top.equalTo(thumbnailImageView.snp.top)
            make.leading.equalTo(thumbnailImageView.snp.trailing).offset(7)
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-10)
            make.height.greaterThanOrEqualTo(55)
        }
        
        mainInfoStackView.addArrangedSubview(titleLabel)
        mainInfoStackView.addArrangedSubview(contentLabel)
        
        contentLabel.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(30)
            make.top.equalTo(titleLabel.snp.bottom)
        }
    }
    
    //MARK: - 댓글, 좋아요 수, 닉네임, 게시날짜 stackview
    private func setupSubInfoStackView() {
        // 댓글, 좋아요 이미지와 count 스택뷰
        firstStackView.axis = .horizontal
        firstStackView.distribution = .equalSpacing
        firstStackView.alignment = .center
        firstStackView.spacing = 5
        
        commentCountLabel.text = "9999"
        commentCountLabel.font = UIFont.systemFont(ofSize: 13, weight: .light)
        bookmarkCountLabel.text = "9999"
        bookmarkCountLabel.font = UIFont.systemFont(ofSize: 13, weight: .light)
        
        
        let commentImageConfig = UIImage.SymbolConfiguration(pointSize: 13, weight: .light)
        let heartImageConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .light)
        commentIcon.image = UIImage(systemName: "message", withConfiguration: commentImageConfig)
        bookmarkIcon.image = UIImage(systemName: "heart", withConfiguration: heartImageConfig)
        

        firstStackView.addArrangedSubview(commentIcon)
        firstStackView.addArrangedSubview(commentCountLabel)
        firstStackView.addArrangedSubview(bookmarkIcon)
        firstStackView.addArrangedSubview(bookmarkCountLabel)
        
        // 닉네임, 게시날짜 스택뷰
        secondStackView.axis = .horizontal
        secondStackView.distribution = .equalSpacing
        secondStackView.alignment = .center
        secondStackView.spacing = 10
        
        nicknameLabel.text = "구현현서"
        nicknameLabel.font = UIFont.systemFont(ofSize: 13, weight: .ultraLight)
        timestampLabel.text = "24.08.05 17:00"
        timestampLabel.font = UIFont.systemFont(ofSize: 13, weight: .ultraLight)
        
        secondStackView.addArrangedSubview(nicknameLabel)
        secondStackView.addArrangedSubview(timestampLabel)
        
        // 오토레이아웃
        self.contentView.addSubview(firstStackView)
        self.contentView.addSubview(secondStackView)
        
        firstStackView.snp.makeConstraints { make in
            make.leading.equalTo(thumbnailImageView.snp.trailing).offset(5)
            make.top.equalTo(mainInfoStackView.snp.bottom)
            make.bottom.equalTo(thumbnailImageView.snp.bottom)
            make.height.equalTo(20)
        }
        
        secondStackView.snp.makeConstraints { make in
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-10)
            make.bottom.equalTo(firstStackView)
        }
    }
    
//    //MARK: - menu 버튼
//    private func setupMenuButton() {
//        myMenu = [ UIAction(title: "게시글 수정하기", image: UIImage(systemName: "square.and.pencil"), handler: { _ in self.editButtonAction() }), UIAction(title: "삭제하기", image: UIImage(systemName: "trash"),attributes: .destructive,handler: { _ in self.deleteButtonAction() }) ]
//        otherMenu = [ UIAction(title: "작성자 차단하기", image: UIImage(systemName: "hand.raised"), handler: { _ in self.blockButtonAction() }), UIAction(title: "신고하기", image: UIImage(systemName: "exclamationmark.bubble"),attributes: .destructive,handler: { _ in self.reportButtonAction() }) ]
//        
//        menuButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
//        menuButton.contentMode = .scaleAspectFit
//        menuButton.transform = CGAffineTransform(rotationAngle: .pi * 0.5)
//        menuButton.showsMenuAsPrimaryAction = true
//        
//        self.contentView.addSubview(menuButton)
//        
//        menuButton.snp.makeConstraints { make in
//            make.top.equalTo(self.contentView).offset(5)
//            make.trailing.equalTo(self.contentView.snp.trailing).offset(-5)
//        }
//    }
    
//    private func editButtonAction() {
//        print("CommunityTableViewCell edit")
//    }
//    
//    private func deleteButtonAction() {
//        print("CommunityTableViewCell delete")
//        delegate?.deleteAlert(cell: self)
//    }
//
//    private func blockButtonAction() {
//        print("CommunityTableViewCell block")
//        delegate?.blockAlert(cell: self)
//    }
//    
//    private func reportButtonAction() {
//        print("CommunityTableViewCell report")
//    }
    
    
    
    func configure(imageName: String, title: String, content: String, createAt: String, commentCount: Int, likeCount: Int, name: String, postUserId: String) {

        thumbnailImageView.setImage(with: imageName)
        
        titleLabel.text = title
        contentLabel.text = content
        timestampLabel.text = createAt
        commentCountLabel.text = "\(commentCount)"
        bookmarkCountLabel.text = "\(likeCount)"
        nicknameLabel.text = name
        
//        let isMine: Bool = postUserId == UserService.shared.currentUserId
        
        
        
//        menuButton.menu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: isMine ? myMenu : otherMenu)
        
//        menuButton.removeFromSuperview()
//        secondStackView.snp.makeConstraints { make in
//            make.trailing.equalTo(self.contentView.snp.trailing).offset(-10)
//            make.bottom.equalTo(firstStackView)
//        }
    }
    
}

