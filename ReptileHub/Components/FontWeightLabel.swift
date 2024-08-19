//
//  FontWeightLabel.swift
//  ReptileHub
//
//  Created by 이상민 on 8/19/24.
//

import UIKit

class FontWeightLabel: UILabel {
    func setFontWeightText(fullText: String, boldText: String, fontSize: CGFloat, weight: UIFont.Weight){
        let baseFont = UIFont.systemFont(ofSize: fontSize)
        let attributedString = NSMutableAttributedString(string: fullText, attributes: [.font: baseFont])
        
        let boldFont = UIFont.systemFont(ofSize: fontSize, weight: weight)
        let range = (fullText as NSString).range(of: boldText)
        attributedString.addAttributes([.font: boldFont], range: range)
        
        self.attributedText = attributedString
    }
}
