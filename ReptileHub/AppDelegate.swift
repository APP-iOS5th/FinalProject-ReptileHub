//
//  AppDelegate.swift
//  ReptileHub
//
//  Created by 조성빈 on 7/25/24.
//

import UIKit
import FirebaseCore
import GoogleSignIn
import KakaoSDKCommon
import KakaoSDKAuth

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        KakaoSDK.initSDK(appKey:"안알랴줌")
       
        
//        AuthService.shared.addAuthStateDidChangeListener { user in
//            if user != nil {
//                self.showMainViewController()
//            } else {
//                self.showLoginViewController()
//            }
//        }
        
        return true
    }
    
    
    func showLoginViewController() {
           let loginVC = LoginViewController()
           window?.rootViewController = loginVC
       }

       func showMainViewController() {
           let mainVC = ViewController()
           window?.rootViewController = mainVC
       }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
//    func application(_ app: UIApplication,
//                     open url: URL,
//                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
//      return GIDSignIn.sharedInstance.handle(url)
//    }


}

