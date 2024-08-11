//
//  CommunityDetailViewController.swift
//  ReptileHub
//
//  Created by 조성빈 on 8/12/24.
//

import UIKit
import SnapKit

class CommunityDetailViewController: UIViewController {
    
    // 상단 게시글 정보
    private let profileImage: UIImageView = UIImageView()
    
    private let titleLabel: UILabel = UILabel()
    private let nicknameLabel: UILabel = UILabel()
    private let timestampLabel: UILabel = UILabel()
    private let elementStackView: UIStackView = UIStackView()
    
    private let menuButton: UIButton = UIButton()
    
    private let titleStackView: UIStackView = UIStackView()
    
    // 상단 게시글 정보와 게시글 본문 사이의 구분선
    private let divisionLine: UIView = UIView()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white

        self.title = "커뮤니티"
        
        setupProfileImage()
        setupElementStackView()
        setupMenuButton()
        setupTitleStackView()
    }
    
    //MARK: - 프로필 이미지
    private func setupProfileImage() {
        profileImage.image = UIImage(systemName: "person")
        profileImage.backgroundColor = .green
        profileImage.layer.cornerRadius = 33
        profileImage.clipsToBounds = true
        profileImage.tintColor = .brown
    }
    
    //MARK: - 제목, 닉네임, 시간 StackView(elementStackView)
    private func setupElementStackView() {
        titleLabel.text = "공부는 최대한 미뤄라."
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        nicknameLabel.text = "공부싫어"
        nicknameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        timestampLabel.text = "24.08.09 17:31"
        timestampLabel.font = UIFont.systemFont(ofSize: 11, weight: .light)
        timestampLabel.textColor = UIColor.lightGray
        
        elementStackView.axis = .vertical
        elementStackView.distribution = .fillEqually
        elementStackView.alignment = .leading
        elementStackView.backgroundColor = .systemPink
        
        elementStackView.addArrangedSubview(titleLabel)
        elementStackView.addArrangedSubview(nicknameLabel)
        elementStackView.addArrangedSubview(timestampLabel)
    }
    
    //MARK: - menu 버튼
    private func setupMenuButton() {
        menuButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        menuButton.contentMode = .scaleAspectFit
        menuButton.transform = CGAffineTransform(rotationAngle: .pi * 0.5)
        menuButton.backgroundColor = .red
    }
    
    //MARK: - title StackView
    private func setupTitleStackView() {
        titleStackView.axis = .horizontal
        titleStackView.distribution = .fill
        titleStackView.alignment = .center
        titleStackView.spacing = 10
        titleStackView.backgroundColor = .yellow
        
        titleStackView.addArrangedSubview(profileImage)
        titleStackView.addArrangedSubview(elementStackView)
        titleStackView.addArrangedSubview(menuButton)
        
        self.view.addSubview(titleStackView)
        
        titleStackView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(self.view.snp.leading).offset(24)
            make.trailing.equalTo(self.view.snp.trailing).offset(-24)
            make.height.equalTo(65)
        }
        
        profileImage.snp.makeConstraints { (make) -> Void in
            make.height.width.equalTo(65)
            make.leading.equalTo(titleStackView.snp.leading)
        }
        
        elementStackView.snp.makeConstraints { (make) -> Void in
            make.leading.equalTo(profileImage.snp.trailing).offset(10)
            make.height.equalTo(50)
        }
        
        menuButton.snp.makeConstraints { (make) -> Void in
            make.trailing.equalTo(titleStackView.snp.trailing)
        }
    }

}
