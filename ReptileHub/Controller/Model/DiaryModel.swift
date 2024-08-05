//
//  DiaryModel.swift
//  ReptileHub
//
//  Created by 임재현 on 8/5/24.
//

import UIKit

struct DiaryRequest {
    var title: String
    var name: String
    var species: String
    var morph: String?
    var hatchDays: Date
    var lizardInfo: LizardInfo
    var parentInfo: Parents?
}

struct LizardInfo {
    var gender:Gender
    var weight: Int
    var feedMethod: String
    var tailexistence: Bool
}

struct Gender {
    var male: String
    var female: String
    var unKnown: String
}

struct ParentInfo {
    var image: UIImage
    var name: String
    var morph: String?
}

struct Parents {
    var mother: ParentInfo
    var father: ParentInfo
}
