//
//  AddGrowthDiary.swift
//  ReptileHub
//
//  Created by 이상민 on 8/19/24.
//

import UIKit
import SnapKit

class AddGrowthDiaryView: UIView {

    private lazy var titleLabel = { (fullText: String, boldText: String) -> FontWeightLabel in
        let label = FontWeightLabel()
        label.setFontWeightText(fullText: fullText, boldText: boldText, fontSize: 20, weight: .semibold)
        label.backgroundColor = .red
        return label
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUI()
    }
    
    private func setUI(){
        let thumnailTitle = titleLabel("썸네일", "썸네일")
        self.addSubview(thumnailTitle)
        
        thumnailTitle.snp.makeConstraints { make in
            make.leading.equalTo(self).offset(Spacing.mainSpacing)
            make.trailing.equalTo(self).offset(-Spacing.mainSpacing)
        }
    }
}

#if DEBUG
import SwiftUI

struct AddGrowthDiaryViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> AddGrowthDiaryView {
        return AddGrowthDiaryView()
    }
    
    func updateUIView(_ uiView: AddGrowthDiaryView, context: Context) {
        // 필요하다면 뷰 업데이트
        uiView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}

struct AddGrowthDiaryView_Previews: PreviewProvider {
    static var previews: some View {
        AddGrowthDiaryViewRepresentable()
            .previewLayout(.sizeThatFits) // 크기를 맞춤 설정할 수 있음
    }
}
#endif
