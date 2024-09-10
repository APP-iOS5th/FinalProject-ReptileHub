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
    
    var currentUserProfile: UserProfile?
    
    var isMyProfile: Bool?
    
    var userProfileData = [String]()
    private var shouldReloadImage = false {
        didSet {
            if shouldReloadImage {
                self.loadData()
                editUserInfo()
                shouldReloadImage = false
            }
        }
    }
    
    private var list = ["내가 작성한 댓글", "북마크한 게시글", "내가 차단한 사용자"]
    
    let profileView = ProfileView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "back", style: .plain, target: nil, action: nil)

        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        UserService.shared.fetchUserProfile(uid: uid) { results in
            switch results {
            case .success(let profile):
                print("porfile: \(profile)")
            case .failure(let error):
                print("error: \(error.localizedDescription)")
            }
        }
        
        self.navigationItem.title = "프로필"
        
        loadData()
        
        self.view = profileView
        profileView.configureListTableView(delegate: self, datasource: self)
        
        let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(editUserInfo))
        barButtonItem.tintColor = .gray
        self.navigationItem.rightBarButtonItem = barButtonItem
        barButtonItem.isHidden = !(self.isMyProfile ?? false)
        
        profileView.firstButton.addTarget(self, action: #selector(myReptileButtonTouch), for: .touchUpInside)
        profileView.secondButton.addTarget(self, action: #selector(writePostButtonTouch), for: .touchUpInside)
        profileView.withdrawalButton.addTarget(self, action: #selector(withdrawalButtonTouch), for: .touchUpInside)
        profileView.logoutButton.addTarget(self, action: #selector(logoutButtonTouch), for: .touchUpInside)
        if !(self.isMyProfile ?? true) {
            profileView.withdrawalButton.isHidden = true
            profileView.logoutButton.isHidden = true
            profileView.centerLabel.isHidden = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileView.updateScrollState()
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        loadData()
    }
    
    func loadData(){ 
        
        // MARK: - 프로필 수정
        UserService.shared.fetchUserProfile(uid: UserService.shared.currentUserId) { result in
            switch result {
            case .success(let userData):
                self.userProfileData.removeAll()
                self.userProfileData.append(contentsOf: [userData.name, userData.profileImageURL])
                self.profileView.firstButton.setTitle(String(userData.lizardCount), for: .normal)
                self.profileView.secondButton.setTitle(String(userData.postCount), for: .normal)
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
    }
    
    // MARK: - 각 버튼 기능
    // 프로필 수정 뷰 모달로 띄우기
    @objc func editUserInfo() {
        let editController = EditUserInfoViewController()
        editController.delegate = self
        editController.editUserInfoData = (userProfileData[0], userProfileData[1])
        if let sheet = editController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        editController.previousViewController = self
        self.present(editController, animated: true, completion: nil)
    }

    // 내 도마뱀 탭바 이동
    @objc func myReptileButtonTouch() {
        if self.isMyProfile ?? true {
            if let tabBarController = self.tabBarController {
                tabBarController.selectedIndex = 1
            }
        }
    }

    // 내가 쓴 게시글 뷰
    @objc func writePostButtonTouch() {
        let writePostController = WritePostListViewController()
        writePostController.fetchUserData = self.currentUserProfile
        self.navigationController?.pushViewController(writePostController, animated: true)
    }

    // 회원탈퇴 (버튼)
    @objc func withdrawalButtonTouch() {
        let alert = UIAlertController(title: "회원탈퇴", message: "ReptileHub 앱을 탈퇴하시겠습니까?", preferredStyle: .alert)
        

        let delete = UIAlertAction(title: "탈퇴", style: .destructive){ [weak self] _ in
            self?.deleteAuthentication()
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(cancel)
        alert.addAction(delete)
        
        present(alert, animated: true)
    }

    private func deleteAuthentication(){
        guard let loginType = currentUserProfile?.loginType else {
            return
        }
        AuthService.shared.deleteUserAccount(userID: UserService.shared.currentUserId, loginType: loginType) { error in
            if let error = error{
                print("ERROR: \(error.localizedDescription)")
            }else{
                print("회원탈퇴가 정상적으로 이루어졌습니다.")
            }
        }
    }
    
    
    // 로그아웃 (버튼)
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
        if !(self.isMyProfile ?? true) && indexPath.row == 2 {
            cell.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    
        switch indexPath.row {
        case 0:
            let writeReplyVC = WriteReplyListViewController()
            writeReplyVC.fetchUserData = self.currentUserProfile
            self.navigationController?.pushViewController(writeReplyVC, animated: true)
        case 1:
            let likePostVC = LikePostViewController()
            likePostVC.fetchUserData = self.currentUserProfile
            self.navigationController?.pushViewController(likePostVC, animated: true)
        case 2:
            let blockUserVC = BlockUserViewController()
            self.navigationController?.pushViewController(blockUserVC, animated: true)
        default:
            return
        }
    
    }
}


extension ProfileViewController: EditUserInfoViewControllerDelegate {
    func tapSaveEditButton(newName: String, newProfileImage: UIImage, targetButton: UIButton) {
        targetButton.isEnabled = false
        guard let uid = Auth.auth().currentUser?.uid else {return}
        UserService.shared.updateUserProfile(uid: uid, newName: newName, newProfileImage: newProfileImage) { [weak self] error in
            //수정 버튼을 클릭하면 비활성화
          
            
            
            defer{
                targetButton.isEnabled = true
            }
            
            if let error = error {
                print("프로필 저장 실패: \(error.localizedDescription)")
            } else {
                print("프로필 저장 성공")
//                if let previousVC = self?.previousViewController{
//                                    print("privousVC", previousVC)
//                                    previousVC.updateImage()
//                                }
                self?.updateImage()
                UserService.shared.fetchUserProfile(uid: UserService.shared.currentUserId) { result in
                    switch result {
                    case .success(let userData):
                        self?.profileView.setProfileData(userData: userData)
                    case .failure(let error):
                        print("error~! : \(error)")
                    }
                }

                self?.dismiss(animated: true,completion: nil)
//                self?.editUserInfoData = nil
            }
        }
    }
    
    
}
