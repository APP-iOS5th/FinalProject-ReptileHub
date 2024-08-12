//
//  GrowthDiaryListView.swift
//  ReptileHub
//
//  Created by 이상민 on 8/12/24.
//

import UIKit

class GrowthDiaryListView: UIView {

    /*
     Only override draw() if you perform custom drawing.
     An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
         Drawing code
    }
    */
    
}

#if DEBUG
import SwiftUI

struct GrowthDiaryListViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> GrowthDiaryListView {
        return GrowthDiaryListView()
    }
    
    func updateUIView(_ uiView: GrowthDiaryListView, context: Context) {
        // 필요하다면 뷰 업데이트
        uiView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}

struct MyCustomView_Previews: PreviewProvider {
    static var previews: some View {
        GrowthDiaryListViewRepresentable()
            .previewLayout(.sizeThatFits) // 크기를 맞춤 설정할 수 있음
    }
}
#endif
