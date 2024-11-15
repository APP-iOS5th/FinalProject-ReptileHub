//
//  DIContainer.swift
//  ReptileHub
//
//  Created by 임재현 on 11/15/24.
//

import UIKit

final class DIContainer {
    let kakaoAuthManager: KaKaoAuthManagerProtocol
    let googleAuthManager: GoogleAuthManagerProtocol
    let appleAuthManager: AppleAuthManagerProtocol
    let authservice: AuthServiceProtocol
    
    init(kakaoAuthManager: KaKaoAuthManagerProtocol = KaKaoAuthManager(),
         googleAuthManager: GoogleAuthManagerProtocol = GoogleAuthManager(),
         appleAuthManager: AppleAuthManagerProtocol = AppleAuthManager()
    ) {
        
        print("DIContainer init()")
        self.kakaoAuthManager = kakaoAuthManager
        self.googleAuthManager = googleAuthManager
        self.appleAuthManager = appleAuthManager
        
        self.authservice = AuthService(kakaoAuthManager: kakaoAuthManager,
                                       googleAuthManager: googleAuthManager,
                                       appleAuthManager: appleAuthManager)
    }
    
    func makeLoginViewModel() -> LoginViewModel {
        return LoginViewModel(authService: authservice)
    }
}
