//
//  ProfileViewController.swift
//  ReptileHub
//
//  Created by 조성빈 on 8/5/24.
//

import UIKit
import SnapKit

var List = ["내가 작성한 댓글", "내가 찜한 게시물", "내가 차단한 사용자"]

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - 프로필 이미지
    private var ProfileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "profile")
        imageView.layer.cornerRadius = 95
        imageView.layer.borderColor = UIColor(red: 226/255.0, green: 226/255.0, blue: 226/255.0, alpha: 1).cgColor
        imageView.layer.borderWidth = 7
        imageView.clipsToBounds = true
        return imageView
    }()

    // MARK: - 프로필 이름
    private var ProfileName: UILabel = {
        let label = UILabel()
        label.text = "해적단"
        label.font = .systemFont(ofSize: 23)
        return label
    }()
    
    // MARK: - 내 도마뱀 스택뷰
    private var FirstLabel: UILabel = {
        let label = UILabel()
        label.text = "내 도마뱀"
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        return label
    }()
    
    private var FirstButton: UIButton = {
        let button = UIButton()
        button.setTitle("3", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(MyReptileButtonTouch), for: .touchUpInside)
        return button
    }()
    
    private lazy var FirstStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [FirstLabel, FirstButton])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    // MARK: - 내가 쓴 게시글 스택뷰
    private var SecondLabel: UILabel = {
        let label = UILabel()
        label.text = "내가 쓴 게시글"
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        return label
    }()
    
    private var SecondButton: UIButton = {
        let button = UIButton()
        button.setTitle("3", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(WritePostButtonTouch), for: .touchUpInside)
        return button
    }()
    
    private lazy var SecondStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [SecondLabel, SecondButton])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    // MARK: - 소셜 로그인 스택뷰
    private var ThirdLabel: UILabel = {
        let label = UILabel()
        label.text = "소셜 로그인"
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        return label
    }()
    
    private var ThirdImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "profile2")
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var ThirdStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [ThirdLabel, ThirdImage])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()
    
    // MARK: - 스택뷰 3개 묶은 스택뷰
    private lazy var LastStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [FirstStackView, SecondStackView, ThirdStackView])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.backgroundColor = .darkGray
        stackView.layer.cornerRadius = CGFloat(5)
        return stackView
    }()
    
    // MARK: - 내가 작성한 댓글, 차단한 유저 등 테이블 뷰
    private var PostList: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    // MARK: - 회원탈퇴 버튼
    private var WithdrawalButton: UIButton = {
        let button = UIButton()
        button.setTitle("회원 탈퇴", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(WithdrawalButtonTouch), for: .touchUpInside)

        return button
    }()
    
    // MARK: - 스택뷰 가운데 짝대기
    private var CenterLabel: UILabel = {
        let label = UILabel()
        label.text = "|"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .center
        label.textColor = .lightGray
        return label
    }()
    
    // MARK: - 로그아웃 버튼
    private var LogoutButton: UIButton = {
        let button = UIButton()
        button.setTitle("로그아웃", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(LogoutButtonTouch), for: .touchUpInside)
        return button
    }()
    
    // MARK: - 회원탈퇴 & 로그아웃 버튼 스택뷰
    private lazy var ButtonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [WithdrawalButton, CenterLabel, LogoutButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "프로필"
        
        // MARK: - 네비게이션 바 아이템 & 프로필 수정
        let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(editUserInfo))
        barButtonItem.tintColor = .gray
        self.navigationItem.rightBarButtonItem = barButtonItem
        
        PostList.delegate = self
        PostList.dataSource = self
        
        view.backgroundColor = .white
        
        view.addSubview(ProfileImage)
        view.addSubview(ProfileName)
        view.addSubview(ThirdImage)
        view.addSubview(LastStackView)
        view.addSubview(PostList)
        view.addSubview(ButtonsStackView)
        
        ProfileImage.snp.makeConstraints { make in
            make.width.height.equalTo(190)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(100)
        }
        
        ProfileName.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(ProfileImage.snp.bottom).offset(10)
        }
        
        ThirdImage.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
        
        LastStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(ProfileName.snp.bottom).offset(30)
            make.height.equalTo(70)
            make.width.equalTo(340)
        }
        
        PostList.snp.makeConstraints { make in
            make.width.equalTo(370)
            make.centerX.equalToSuperview()
            make.top.equalTo(LastStackView.snp.bottom).offset(20)
            make.height.equalTo(65 * List.count)
        }
        
        ButtonsStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(PostList.snp.bottom).offset(50)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return List.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = List[indexPath.row]
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        
        let symbol = UIImageView(image: UIImage(systemName: "chevron.right"))
        symbol.tintColor = .black
        cell.accessoryView = symbol
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let viewController: UIViewController
        switch indexPath.row {
        case 0:
            viewController = WriteReplyListViewController()
        case 1:
            viewController = LikePostViewController()
        case 2:
            viewController = BlockListViewController()
        default:
            return
        }
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: - 유저 프로필 수정 모달 띄우는 기능 (버튼)
    @objc func editUserInfo() {
        let editController = EditUserInfoViewController()
        
        if let sheet = editController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        self.present(editController, animated: true, completion: nil)
    }
    
    // MARK: - 내 도마뱀 뷰로 이동 (네비게이션)
    @objc func MyReptileButtonTouch() {
        let myReptileController = ReptileViewController()
        self.navigationController?.pushViewController(myReptileController, animated: true)
    }
    
    // MARK: - 내가 작성한 게시글 뷰로 이동 (네비게이션)
    @objc func WritePostButtonTouch() {
        let writePostController = WritePostViewController()
        self.navigationController?.pushViewController(writePostController, animated: true)
    }
    
    // TODO: - 회원탈퇴 버튼
    @objc func WithdrawalButtonTouch() {
        print("회원탈퇴 버튼 터치")
    }
    
    // TODO: - 로그아웃 기능
    @objc func LogoutButtonTouch() {
        print("로그아웃 버튼 터치")
    }
   
}
