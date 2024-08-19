//
//  CommentTableViewCell.swift
//  ReptileHub
//
//  Created by 조성빈 on 8/18/24.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    
    // 상단 게시글 정보
    private let profileImage: UIImageView = UIImageView()
    
    let titleLabel: UILabel = UILabel()
    let commentLabel: UILabel = UILabel()
    let timestampLabel: UILabel = UILabel()
    let elementStackView: UIStackView = UIStackView()
    
    private var menuButton: UIButton = UIButton()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: - 프로필 이미지
    private func setupProfileImage() {
        profileImage.image = UIImage(systemName: "person")
        profileImage.backgroundColor = .green
        profileImage.layer.cornerRadius = 20
        profileImage.clipsToBounds = true
        
        self.contentView.addSubview(profileImage)
        
        profileImage.snp.makeConstraints { make in
            make.height.width.equalTo(40)
            make.top.equalTo(self.contentView.snp.top).offset(5)
            make.leading.equalTo(self.contentView.snp.leading).offset(2)
        }
    }
    
    //MARK: - 제목, 닉네임, 시간 StackView(elementStackView)
    private func setupElementStackView() {
        titleLabel.text = "부천 정구현"
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        commentLabel.text = "(주먹을 들고 째려보며) 야. 죽을래?(주먹을 들고 째려보며) 야. 죽을래?(주먹을 들고 째려보며) 야. 죽을래?(주먹을 들고 째려보며) 야. 죽을래?(주먹을 들고 째려보며) 야. 죽을래?(주먹을 들고 째려보며) 야. 죽을래?(주먹을 들고 째려보며) 야. 죽을래?(주먹을 들고 째려보며) 야. 죽을래?(주먹을 들고 째려보며) 야. 죽을래?"
        commentLabel.numberOfLines = 0
        commentLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        timestampLabel.text = "24.08.09 17:31"
        timestampLabel.font = UIFont.systemFont(ofSize: 10, weight: .light)
        timestampLabel.textColor = UIColor.lightGray
        
        elementStackView.axis = .vertical
        elementStackView.distribution = .fill
        elementStackView.alignment = .leading
        elementStackView.spacing = 3
        elementStackView.backgroundColor = .systemPink
        
        elementStackView.addArrangedSubview(titleLabel)
        elementStackView.addArrangedSubview(commentLabel)
        elementStackView.addArrangedSubview(timestampLabel)
        
        self.contentView.addSubview(elementStackView)
        
        elementStackView.snp.makeConstraints { make in
            make.top.equalTo(self.contentView.snp.top).offset(5)
            make.leading.equalTo(profileImage.snp.trailing).offset(10)
            make.trailing.equalTo(menuButton.snp.leading).offset(10)
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-5)
            make.height.greaterThanOrEqualTo(10)
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
        
        menuButton.addTarget(self, action: #selector(actionMenuButton), for: .touchUpInside)
            
        self.contentView.addSubview(menuButton)
        
        menuButton.snp.makeConstraints { make in
            make.top.equalTo(self.contentView.snp.top).offset(10)
            make.trailing.equalTo(self.contentView.snp.trailing)
        }
    }
    
    @objc
    private func actionMenuButton() {
        print("메뉴 버튼 클릭.")
    }
    
    //MARK: - configure cell
    func configureCell() {
        setupProfileImage()
        setupMenuButton()
        setupElementStackView()
    }

}
