//
//  UIDatePickerExtension.swift
//  ReptileHub
//
//  Created by 이상민 on 8/28/24.
//

import Foundation

//MARK: - 0000.00.00 형식으로 날짜추출
extension Date{
    var formatted: String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy. MM. dd"
        return formatter.string(from: self)
    }
}
