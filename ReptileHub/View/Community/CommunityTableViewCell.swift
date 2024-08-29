//
//  CommunityTableViewCell.swift
//  ReptileHub
//
//  Created by 조성빈 on 8/8/24.
//

import UIKit
import SnapKit

class CommunityTableViewCell: UITableViewCell {
    
    var testThumbnail: ThumbnailPostResponse? {
        didSet {
            guard let testThumbnail = testThumbnail else { return }
            URLSession.shared.dataTask(with: URL(string: testThumbnail.thumbnailURL)!) { [weak self] data, response, error in
                guard let self,
                      let data = data,
                      response != nil,
                      error == nil else { return }
                DispatchQueue.main.async {
                    self.thumbnailImageView.image = UIImage(data: data) ?? UIImage()
                }
            }.resume()
            self.titleLabel.text = testThumbnail.title
            self.contentLabel.text = testThumbnail.previewContent
            self.bookmarkCountLabel.text = "\(testThumbnail.likeCount)"
            self.commentCountLabel.text = "\(testThumbnail.commentCount)"
            //            self.timestampLabel.text = "\(testThumbnail.createdAt)"
            // 추가로 이미지와 다른 데이터도 업데이트
        }
    }
    
    lazy var thumbnailImageView: UIImageView = UIImageView()
    
    lazy var titleLabel: UILabel = UILabel()
    private let contentLabel: UILabel = UILabel()
    private let mainInfoStackView: UIStackView = UIStackView()
    
    private let commentIcon: UIImageView = UIImageView(image: UIImage(systemName: "message"))
    private let commentCountLabel: UILabel = UILabel()
    private let bookmarkIcon: UIImageView = UIImageView(image: UIImage(systemName: "heart"))
    private let bookmarkCountLabel: UILabel = UILabel()
    private let firstStackView: UIStackView = UIStackView()
    
    private let nicknameLabel: UILabel = UILabel()
    private let timestampLabel: UILabel = UILabel()
    private let secondStackView: UIStackView = UIStackView()
    
    private let menuButton: UIButton = UIButton()
    
    
    //    override func awakeFromNib() {
    //        super.awakeFromNib()
    //    }
    //
    //    override func setSelected(_ selected: Bool, animated: Bool) {
    //        super.setSelected(selected, animated: animated)
    //    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupThumbnail()
        setupMenuButton()
        setupSubInfoStackView()
        setupMainInfoStackView()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.titleLabel.text = testThumbnail?.title
    }
    
    //MARK: - Thumnail Image
    private func setupThumbnail() {
        thumbnailImageView.image = UIImage(systemName: "camera")
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.layer.cornerRadius = 5
        thumbnailImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        thumbnailImageView.backgroundColor = .lightGray
        
        self.contentView.addSubview(thumbnailImageView)
        
        thumbnailImageView.snp.makeConstraints { make in
            make.height.width.equalTo(71)
            make.centerY.equalTo(self.contentView)
            make.leading.equalTo(self.contentView.snp.leading).offset(12)
        }
    }
    
    //MARK: - 제목, 내용 StackView
    private func setupMainInfoStackView() {
        mainInfoStackView.axis = .vertical
        mainInfoStackView.distribution = .fill
        mainInfoStackView.alignment = .leading
        mainInfoStackView.backgroundColor = .red
        
        titleLabel.text = testThumbnail?.title ?? "nil"
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        titleLabel.backgroundColor = .green
        contentLabel.text = testThumbnail?.previewContent ?? "nil"
        contentLabel.numberOfLines = 0
        contentLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        contentLabel.backgroundColor = .yellow
        
        self.contentView.addSubview(mainInfoStackView)
        
        mainInfoStackView.snp.makeConstraints { make in
            make.top.equalTo(thumbnailImageView.snp.top)
            make.leading.equalTo(thumbnailImageView.snp.trailing).offset(5)
            make.bottom.equalTo(firstStackView.snp.top)
            make.trailing.equalTo(menuButton.snp.leading)
            make.height.equalTo(55)
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
        
        commentCountLabel.text = "\(testThumbnail?.likeCount ?? 9999)"
        commentCountLabel.font = UIFont.systemFont(ofSize: 12, weight: .light)
        bookmarkCountLabel.text = "\(testThumbnail?.commentCount ?? 9999)"
        bookmarkCountLabel.font = UIFont.systemFont(ofSize: 12, weight: .light)
        
        commentIcon.snp.makeConstraints {
            $0.width.equalTo(15)
        }
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
        nicknameLabel.font = UIFont.systemFont(ofSize: 12, weight: .ultraLight)
        timestampLabel.text = "24.08.05 17:00"
        timestampLabel.font = UIFont.systemFont(ofSize: 12, weight: .ultraLight)
        
        secondStackView.addArrangedSubview(nicknameLabel)
        secondStackView.addArrangedSubview(timestampLabel)
        
        // 오토레이아웃
        self.contentView.addSubview(firstStackView)
        self.contentView.addSubview(secondStackView)
        
        firstStackView.snp.makeConstraints { make in
            make.leading.equalTo(thumbnailImageView.snp.trailing).offset(5)
            make.bottom.equalTo(thumbnailImageView.snp.bottom)
        }
        
        secondStackView.snp.makeConstraints { make in
            make.trailing.equalTo(menuButton.snp.centerX)
            make.bottom.equalTo(firstStackView.snp.bottom)
        }
    }
    
    //MARK: - menu 버튼
    private func setupMenuButton() {
        menuButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        menuButton.contentMode = .scaleAspectFit
        menuButton.transform = CGAffineTransform(rotationAngle: .pi * 0.5)
        
        self.contentView.addSubview(menuButton)
        
        menuButton.snp.makeConstraints { make in
            make.top.equalTo(self.contentView).offset(5)
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-12)
            
        }
    }
    
}
