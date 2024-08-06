//
//  DiaryModel.swift
//  ReptileHub
//
//  Created by 임재현 on 8/5/24.
//

import UIKit

struct DiaryRequest:Codable {
    var name: String
    var species: String
    var morph: String?
    var hatchDays: Date
    var lizardInfo: LizardInfo
    var parentInfo: Parents?
    var imageURL: String?
}

struct LizardInfo:Codable {
    var gender:Gender
    var weight: Int
    var feedMethod: String
    var tailexistence: Bool
}

enum Gender:String,Codable {
    case male = "male"
    case female = "female"
    case unKnown = "unKnown"
}

struct ParentInfo:Codable {
    var image: Data
    var name: String
    var morph: String?
    var imageURL: String?
}

struct Parents:Codable {
    var mother: ParentInfo
    var father: ParentInfo
}
