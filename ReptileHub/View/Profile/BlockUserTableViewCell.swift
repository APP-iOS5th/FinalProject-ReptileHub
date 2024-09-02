//
//  BlockUserTableViewCell.swift
//  Reptile_Hub_UI
//
//  Created by 육현서 on 8/14/24.
//

import UIKit
import SnapKit

class BlockUserTableViewCell: UITableViewCell {
    
    // BlockUserProfile 더미 데이터
    let blockedUsers: [BlockUserProfile] = [
        BlockUserProfile(uid: "001", name: "놀고싶다", profileImageURL: "blockUserProfile")
    ]
    
    private let BlockUserImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    // 블러 효과 뷰
    private let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.isHidden = false
        return blurView
    }()
    
    // Eye slash 시스템 이미지 뷰
    private let eyeSlashImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(systemName: "eye.slash.fill")
        imageView.image = image
        imageView.tintColor = .darkGray
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = false
        return imageView
    }()
    
    private let BlockUserName: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private let BlockCancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("차단해제", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        button.backgroundColor = .addBtnGraphTabbar
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(selectBlockCancel), for: .touchUpInside)
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [BlockUserImage, BlockUserName, BlockCancelButton])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setBlockUserImage()
        setBlockUserName()
        
        contentView.addSubview(stackView)
        BlockUserImage.addSubview(blurEffectView)
        BlockUserImage.addSubview(eyeSlashImageView)
        
        // SnapKit을 사용한 오토레이아웃 설정
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 30, bottom: 8, right: 30))
        }
        
        BlockUserImage.snp.makeConstraints { make in
            make.width.height.equalTo(50)
        }
        
        BlockCancelButton.snp.makeConstraints { make in
            make.width.equalTo(60)
            make.height.equalTo(25)
        }
        
        blurEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview() // 블러 뷰를 이미지 뷰에 완전히 맞춤
        }
        
        eyeSlashImageView.snp.makeConstraints { make in
            make.center.equalToSuperview() // 이미지 뷰의 중앙에 위치시킴
            make.width.height.equalTo(20) // 아이콘의 크기를 설정
        }
        
        // 이미지 뷰에 제스처 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleBlurEffect))
        BlockUserImage.addGestureRecognizer(tapGesture)
    }
    
    
    private func setBlockUserImage() {
        BlockUserImage.image = UIImage(named: blockedUsers[0].profileImageURL)
    }
    
    private func setBlockUserName() {
        BlockUserName.text = blockedUsers[0].name
    }
    
    @objc private func toggleBlurEffect() {
        blurEffectView.isHidden.toggle()
        eyeSlashImageView.isHidden.toggle()
    }
    
    @objc private func selectBlockCancel() {
        print("차단 해제 버튼 ~")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
