//
//  BlockUserTableViewCell.swift
//  Reptile_Hub_UI
//
//  Created by 육현서 on 8/14/24.
//

import UIKit
import SnapKit

protocol BlockUserTableViewCellDelegate: AnyObject {
    func deleteBlockAction(cell: BlockUserTableViewCell)
}

class BlockUserTableViewCell: UITableViewCell {
    
    weak var delegate: BlockUserTableViewCellDelegate?
    
    // MARK: - 차단 유저 셀 구성요소
    // 차단 유저 프로필 이미지
    private let BlockUserImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    // 블러 효과 뷰 -> 차단 유저 프로필 이미지 블러
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
    
    // 차단 유저 이름
    private let BlockUserName: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    // 차단해제 버튼
    private let BlockCancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("차단해제", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        button.backgroundColor = .addBtnGraphTabbar
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(selectBlockCancel), for: .touchUpInside)
        return button
    }()
    
    // 차단유저 프로필 + 차단버튼 스택뷰
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [BlockUserImage, BlockUserName, BlockCancelButton])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        contentView.addSubview(stackView)
        BlockUserImage.addSubview(blurEffectView)
        BlockUserImage.addSubview(eyeSlashImageView)
        
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
            make.edges.equalToSuperview()
        }
        
        eyeSlashImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        // MARK: - 블러처리 텝 제스처
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleBlurEffect))
        BlockUserImage.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - 차단 유저 데이터
    func setBlockUserData(blockUserData: BlockUserProfile) {
        BlockUserImage.setImage(with: blockUserData.profileImageURL)
        BlockUserName.text = blockUserData.name
    }
    
    @objc private func toggleBlurEffect() {
        blurEffectView.isHidden.toggle()
        eyeSlashImageView.isHidden.toggle()
    }
    
    
    @objc private func selectBlockCancel() {
        print("차단 해제 버튼 ~")
        self.delegate?.deleteBlockAction(cell: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
