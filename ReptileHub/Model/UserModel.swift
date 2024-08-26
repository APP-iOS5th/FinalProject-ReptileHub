//
//  UserModel.swift
//  ReptileHub
//
//  Created by 임재현 on 8/16/24.
//

import Foundation

struct BlockUserProfile {
    let uid: String
    let name: String
    let profileImageURL: String
}

struct UserProfile {
    var uid: String
    let name: String
    let profileImageURL: String
    let loginType: String
    var lizardCount: Int
    var postCount: Int
}
