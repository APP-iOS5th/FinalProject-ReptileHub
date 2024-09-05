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
    
    private var list = ["내가 작성한 댓글", "내가 찜한 게시물", "내가 차단한 사용자"]
    
    private let profileView = ProfileView()
    
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
    
    @objc func editUserInfo() {
        let editController = EditUserInfoViewController()
        
        if let sheet = editController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        self.present(editController, animated: true, completion: nil)
    }

    @objc func myReptileButtonTouch() {
        let myReptileController = ReptileViewController()
        self.navigationController?.pushViewController(myReptileController, animated: true)
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
        
        do {
            // Firebase에서 로그아웃 시도
            try Auth.auth().signOut()
            
            // 성공적으로 로그아웃되었으면 루트 뷰 컨트롤러를 로그인 화면으로 변경
            let loginVC = LoginViewController()
            loginVC.modalPresentationStyle = .fullScreen
            
            // 윈도우의 rootViewController를 변경하여 로그인 화면을 표시
            if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate {
                sceneDelegate.window?.rootViewController = loginVC
            }
            
        } catch let error {
            print("로그아웃 실패: \(error.localizedDescription)")
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
