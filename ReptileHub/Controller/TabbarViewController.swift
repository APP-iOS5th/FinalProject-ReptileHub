//
//  TabbarViewController.swift
//  ReptileHub
//
//  Created by 조성빈 on 8/8/24.
//

import UIKit

class TabbarViewController: UITabBarController {

    let communityVC = CommunityViewController()
    let diaryVC = GrowthDiaryViewController()
    let profileVC = ProfileViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        let firstNavigationController = UINavigationController(rootViewController: communityVC)
        let secondNavigationController = UINavigationController(rootViewController: diaryVC)
        let thirdNavigationController = UINavigationController(rootViewController: profileVC)
        
        firstNavigationController.tabBarItem = UITabBarItem(title: "홈", image: UIImage(systemName: "house"), tag: 0)
        secondNavigationController.tabBarItem = UITabBarItem(title: "성장일지", image: UIImage(systemName: "book"), tag: 1)
        thirdNavigationController.tabBarItem = UITabBarItem(title: "프로필", image: UIImage(systemName: "person"), tag: 2)
        
        self.viewControllers = [firstNavigationController, secondNavigationController, thirdNavigationController]
    }
    

    
    

    

}
