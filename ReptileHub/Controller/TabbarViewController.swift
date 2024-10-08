//
//  TabbarViewController.swift
//  ReptileHub
//
//  Created by 조성빈 on 8/8/24.
//

import UIKit
import FirebaseAuth

class TabbarViewController: UITabBarController {

    let communityVC = CommunityViewController()
    let diaryVC = GrowthDiaryViewController()
    let profileVC = ProfileViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = Auth.auth().currentUser {
            print("currentUser ----------------------  \(user.uid)")
        }

        UserService.shared.fetchUserProfile(uid: UserService.shared.currentUserId) { result in
            switch result {
            case .success(let userData):
                self.profileVC.profileView.setProfileData(userData: userData)
                self.profileVC.currentUserProfile = userData
                self.profileVC.profileView.secondButton.setTitle(String(userData.postCount), for: .normal)
                self.profileVC.isMyProfile = true
            case .failure(let error):
                print("끄아아아아아아악!!! : \(error.localizedDescription)")
            }
        }

        let firstNavigationController = UINavigationController(rootViewController: communityVC)
        let secondNavigationController = UINavigationController(rootViewController: diaryVC)
        let thirdNavigationController = UINavigationController(rootViewController: profileVC)
        
        firstNavigationController.tabBarItem = UITabBarItem(title: "홈", image: UIImage(systemName: "house"), tag: 0)
        secondNavigationController.tabBarItem = UITabBarItem(title: "성장일지", image: UIImage(systemName: "book"), tag: 1)
        thirdNavigationController.tabBarItem = UITabBarItem(title: "프로필", image: UIImage(systemName: "person"), tag: 2)
        
        self.viewControllers = [firstNavigationController, secondNavigationController, thirdNavigationController]
        self.tabBar.tintColor = .addBtnGraphTabbar
    }
    
}

