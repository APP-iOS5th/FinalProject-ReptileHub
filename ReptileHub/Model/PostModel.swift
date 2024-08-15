//
//  PostModel.swift
//  ReptileHub
//
//  Created by 임재현 on 8/15/24.
//

import Foundation

struct ThumbnailPostResponse: Codable {
    var postID: String
    var title: String
    var userID: String
    var thumbnailURL:String
    var previewContent: String
    var likeCount: Int
    var commentCount: Int
    var createdAt: Date?
}


struct PostDetailResponse: Codable {
    let postID: String
    let title: String
    let content: String
    let imageURLs: [String]
    let likeCount: Int
    let commentCount: Int
   var createdAt: Date?
}
