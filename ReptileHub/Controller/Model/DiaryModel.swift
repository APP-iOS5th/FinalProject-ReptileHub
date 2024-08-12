//
//  DiaryModel.swift
//  ReptileHub
//
//  Created by 임재현 on 8/5/24.
//

import UIKit

struct DiaryRequest:Codable {
    var lizardInfo: LizardInfo
    var parentInfo: Parents?
}

struct LizardInfo:Codable {
    var name: String
    var species: String
    var morph: String?
    var hatchDays: Date
    var gender:Gender
    var weight: Int
    var feedMethod: String
    var tailexistence: Bool
    var imageURL: String?
}

enum Gender:String,Codable {
    case male = "male"
    case female = "female"
    case unKnown = "unKnown"
}

struct ParentInfo:Codable {
    var name: String
    var morph: String?
    var imageURL: String?
}

struct Parents:Codable {
    var mother: ParentInfo
    var father: ParentInfo
}


struct DiaryResponse: Codable {
    var lizardInfo: LizardInfoResponse
    var parentInfo: ParentsResponse?
}

struct LizardInfoResponse: Codable {
    var name: String
    var species: String
    var morph: String?
    var hatchDays: Date
    var imageURL: String?
    var gender: String
    var weight: Int
    var feedMethod: String
    var tailexistence: Bool
}

struct ParentInfoResponse: Codable {
    var name: String
    var morph: String?
    var imageURL: String?
}

struct ParentsResponse: Codable {
    var mother: ParentInfoResponse
    var father: ParentInfoResponse
}

struct ThumbnailData: Codable {
    var diary_id: String
    var thumbnail: String
    var name: String
}
