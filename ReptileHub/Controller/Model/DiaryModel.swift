//
//  DiaryModel.swift
//  ReptileHub
//
//  Created by 임재현 on 8/5/24.
//

import UIKit

// 도마뱀 등록할때 사용하는 구조체
struct GrowthDiaryRequest:Codable {
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

// 도마뱀 정보 받아올떄 사용하는 구조체
struct GrowthDiaryResponse: Codable {
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


// 성장일지 속 성장일기 작성할때 사용하는 구조체
struct DiaryRequest {
    let title: String
    let content: String
    let imageURLs: [String?]
}

// 성장일기 받아올때 사용하는 구조체
struct DiaryResponse:Codable {
    let title: String
    let content: String
    let imageURLs: [String]
    let createdAt: Date?
}
