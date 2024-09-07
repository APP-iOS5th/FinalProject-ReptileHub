//
//  ProfileViewController.swift
//  ReptileHub
//
//  Created by 조성빈 on 8/5/24.
//

import UIKit
import SnapKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    var userProfileData = [String]()
    private var shouldReloadImage = false {
        didSet {
            print("모몽가\(shouldReloadImage)")

            if shouldReloadImage {
                self.loadData()
                print("고양이")
                editUserInfo()
                shouldReloadImage = false
            }
        }
    }
    
    private var list = ["내가 작성한 댓글", "북마크한 게시글", "내가 차단한 사용자"]
    
    let profileView = ProfileView()
    
    override func loadView() {
        super.viewDidLoad()
        
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        UserService.shared.fetchUserProfile(uid: uid) { results in
            print("지금 프로필 검색 uid -\(uid)") 
            switch results {
                
            case .success(let profile):
                print("porfile \(profile)")
            case .failure(let error):
                print("error \(error.localizedDescription)")
            }
        }
        
        
        
        self.navigationItem.title = "프로필"
        print("쿠키런 조아")
        
        loadData()
        
        self.view = profileView
        profileView.configureListTableView(delegate: self, datasource: self)
        
        let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(editUserInfo))
        barButtonItem.tintColor = .gray
        self.navigationItem.rightBarButtonItem = barButtonItem
        
        profileView.firstButton.addTarget(self, action: #selector(myReptileButtonTouch), for: .touchUpInside)
        profileView.secondButton.addTarget(self, action: #selector(writePostButtonTouch), for: .touchUpInside)
        profileView.withdrawalButton.addTarget(self, action: #selector(withdrawalButtonTouch), for: .touchUpInside)
        profileView.logoutButton.addTarget(self, action: #selector(logoutButtonTouch), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileView.updateScrollState()
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        loadData()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("배고파요")
      
    }
    
    func loadData(){ 
        
        UserService.shared.fetchUserProfile(uid: Auth.auth().currentUser?.uid ?? "nil") { result in
            switch result {
            case .success(let userData):
                self.profileView.setProfileData(userData: userData)
                self.userProfileData.removeAll()
                self.userProfileData.append(contentsOf: [userData.name, userData.profileImageURL])

                self.profileView.postList.reloadData()
                print("userData: \(userData)")
                print("불러오기 성공: \(self.userProfileData)")
            case .failure(let error):
                print("불러오기 실패: \(error.localizedDescription)")
            }
        }
    }
    
    func updateImage() {
        // 다른 뷰 컨트롤러에서 돌아왔을 때 이미지를 다시 로드해야 하는 경우
        shouldReloadImage = true
        print("강아지")
    }
    
    @objc func editUserInfo() { 
        let editController = EditUserInfoViewController()
        editController.editUserInfoData = (userProfileData[0], userProfileData[1])
        if let sheet = editController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        editController.previousViewController = self
        self.present(editController, animated: true, completion: nil)
    }

    @objc func myReptileButtonTouch() {
//        let myReptileController = GrowthDiaryViewController()
//        self.navigationController?.pushViewController(myReptileController, animated: true)
        
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 1
        }
    }

    @objc func writePostButtonTouch() {
        let writePostController = WritePostListViewController()
        self.navigationController?.pushViewController(writePostController, animated: true)
    }

    @objc func withdrawalButtonTouch() {
        print("회원탈퇴 버튼 터치")
    }

    @objc func logoutButtonTouch() {
        print("로그아웃 버튼 터치")
        
        // AuthService의 로그아웃 메서드 호출)
        AuthService.shared.logout { success in
            if success {
                print("DEBUG: 로그아웃 성공")
                
                // 로그인 화면으로 이동
                DispatchQueue.main.async {
                    let loginVC = LoginViewController()
                    loginVC.modalPresentationStyle = .fullScreen
                    
                    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                        sceneDelegate.window?.rootViewController = loginVC
                    }
                }
            } else {
                print("DEBUG: 로그아웃 실패")
            }
        }
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = list[indexPath.row]
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
            viewController = BlockUserViewController()
        default:
            return
        }
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}
