//
//  GoogleAuthManager.swift
//  ReptileHub
//
//  Created by 임재현 on 11/20/24.
//

import Combine
import UIKit
import GoogleSignIn
import FirebaseAuth
import FirebaseCore

protocol GoogleAuthManagerProtocol {
    func login(presentingViewController: UIViewController) -> AnyPublisher<GoogleAuthUser,Error>
}

final class GoogleAuthManager: GoogleAuthManagerProtocol {
    func login(presentingViewController: UIViewController) -> AnyPublisher<GoogleAuthUser,Error> {
        return Future<GoogleAuthUser, Error> { promise in
            print("구글 로그인")
            
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                let error = NSError(domain: "GoogleAuth",
                                    code: -1,
                                    userInfo: [NSLocalizedDescriptionKey:"Goggle Sign in user 찾기 에러"])
                promise(.failure(error))
                return

            }
            
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
            
                GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
                    if let error = error {
                        print("Google Sign-In 에러 발생: \(error.localizedDescription)")
                        promise(.failure(error))
                        return
                    }
                    
                    guard let user = result?.user else {
                        let error = NSError(domain: "GoogleAuth", 
                                            code: -1,
                                            userInfo: [NSLocalizedDescriptionKey:"Goggle Sign in user 찾기 에러"])
                        promise(.failure(error))
                        return
                    }
                    
                    let googleUser = GoogleAuthUser(user: user)
                    promise(.success(googleUser))
                }
            }
            .eraseToAnyPublisher()
        }
    }

