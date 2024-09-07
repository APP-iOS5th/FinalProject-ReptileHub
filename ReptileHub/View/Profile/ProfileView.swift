//
//  ProfileView.swift
//  ReptileHub
//
//  Created by 육현서 on 8/24/24.
//

import UIKit
import SnapKit

class ProfileView: UIView {
    
    // 배경 수정 필요

    // MARK: - Properties (프로필 이미지, 이름, 스택뷰, 테이블뷰 등)
    private let profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 95
        imageView.layer.borderColor = UIColor(red: 226/255.0, green: 226/255.0, blue: 226/255.0, alpha: 1).cgColor
        imageView.layer.borderWidth = 7
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private var profileName: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 23)
        return label
    }()
    
    private let firstLabel: UILabel = {
        let label = UILabel()
        label.text = "내 도마뱀"
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        return label
    }()
    
    let firstButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
    }()
    
    private lazy var firstStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [firstLabel, firstButton])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    private let secondLabel: UILabel = {
        let label = UILabel()
        label.text = "내가 쓴 게시글"
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        return label
    }()
    
    let secondButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
    }()
    
    private lazy var secondStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [secondLabel, secondButton])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    private let thirdLabel: UILabel = {
        let label = UILabel()
        label.text = "소셜 로그인"
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        return label
    }()
    
    private let thirdImage: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var thirdStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [thirdLabel, thirdImage])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var lastStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [firstStackView, secondStackView, thirdStackView])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.backgroundColor = .addBtnGraphTabbar
        stackView.layer.cornerRadius = CGFloat(5)
        return stackView
    }()
    
    private (set) var postList: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    let withdrawalButton: UIButton = {
        let button = UIButton()
        button.setTitle("회원 탈퇴", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        return button
    }()
    
    let centerLabel: UILabel = {
        let label = UILabel()
        label.text = "|"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .center
        label.textColor = .lightGray
        return label
    }()
    
    let logoutButton: UIButton = {
        let button = UIButton()
        button.setTitle("로그아웃", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        return button
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [withdrawalButton, centerLabel, logoutButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var profileScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        
        return scrollView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Views
    private func setupView() {
        self.backgroundColor = .white
        
        self.addSubview(profileScrollView)
        
        profileScrollView.addSubview(profileImage)
        profileScrollView.addSubview(profileName)
        profileScrollView.addSubview(thirdImage)
        profileScrollView.addSubview(lastStackView)
        profileScrollView.addSubview(postList)
        profileScrollView.addSubview(buttonsStackView)
        
        profileScrollView.snp.makeConstraints { make in
            make.edges.equalTo(self.safeAreaLayoutGuide)
        }
        
        profileImage.snp.makeConstraints { make in
            make.width.height.equalTo(190)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20)
        }
        
        profileName.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(profileImage.snp.bottom).offset(10)
        }
        
        thirdImage.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
        
        lastStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(profileName.snp.bottom).offset(30)
            make.height.equalTo(70)
            make.width.equalTo(340)
        }
        
        postList.snp.makeConstraints { make in
            make.width.equalTo(370)
            make.centerX.equalToSuperview()
            make.top.equalTo(lastStackView.snp.bottom).offset(20)
            make.height.equalTo(65 * 3)
        }
        
        buttonsStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(postList.snp.bottom).offset(30)
            make.bottom.equalTo(profileScrollView.snp.bottom).offset(-40)
        }
    }
    
    func setProfileData(userData: UserProfile) {
        profileImage.setImage(with: userData.profileImageURL) // 
        profileName.text = userData.name
        firstButton.setTitle(String(userData.lizardCount), for: .normal)
        print("포스트 카운트 : \(userData.postCount)")
        secondButton.setTitle(String(userData.postCount), for: .normal)
        thirdImage.image = UIImage(named: userData.loginType)
    }
    
    func configureListTableView(delegate: UITableViewDelegate, datasource: UITableViewDataSource) {
        postList.delegate = delegate
        postList.dataSource = datasource
    }
    
    func updateScrollState(){
        profileScrollView.setNeedsLayout()
        profileScrollView.layoutIfNeeded()
        
        if profileScrollView.contentSize.height > profileScrollView.bounds.height{
            profileScrollView.isScrollEnabled = true
        }else{
            profileScrollView.isScrollEnabled = false
        }
    }
}
