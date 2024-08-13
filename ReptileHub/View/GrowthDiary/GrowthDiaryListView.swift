//
//  GrowthDiaryListView.swift
//  ReptileHub
//
//  Created by 이상민 on 8/12/24.
//

import UIKit
import SnapKit

class GrowthDiaryListView: UIView {
    //MARK: - 상단 텍스트 Label
    private lazy var GrowthDiaryTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "사랑하는 반려도마뱀의 하루하루를 기록해보세요!"
        label.font = UIFont.systemFont(ofSize: 28)
        label.numberOfLines = 0
        label.asFont(rangeText: "하루하루를 기록해보세요!", font: UIFont.systemFont(ofSize: 28, weight: .bold))
        return label
    }()
    
    //MARK: - 성장일지 등록페이지 이동 버튼
    private lazy var GrowthDiaryUploadViewMoveButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 5
        
        var config = UIButton.Configuration.filled()
        //AttributedString 설정
        var buttonText = AttributedString("새로운 반려 도마뱀 등록하기") //텍스트 정의
        
        //AttributeContainer 생성 및 폰트, 색상 설정
        var attributes = AttributeContainer()
        attributes.font = UIFont.systemFont(ofSize: 18, weight: .semibold) //폰트크기 설정
        
        //AttributedString에 속성 적용
        buttonText.mergeAttributes(attributes)
        
        config.attributedTitle = buttonText
        // TODO: ColorSet으로 설정해서 사용하기
        config.baseBackgroundColor = UIColor(red: 11.0/255.0, green: 71.0/255.0, blue: 59.0/255.0, alpha: 1.0)
        config.baseForegroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 0, bottom: 14, trailing: 0)
        button.configuration = config
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUI()
    }
    
    private func setUI(){
        self.addSubview(GrowthDiaryTitleLabel)
        self.addSubview(GrowthDiaryUploadViewMoveButton)
        
        GrowthDiaryTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(self).offset(Spacing.mainSpacing)
            make.trailing.equalTo(self).offset(-Spacing.mainSpacing)
            make.top.equalTo(self).offset(40)
        }
        
        GrowthDiaryUploadViewMoveButton.snp.makeConstraints { make in
            make.leading.equalTo(self).offset(Spacing.mainSpacing)
            make.trailing.equalTo(self).offset(-Spacing.mainSpacing)
            make.bottom.equalTo(self).offset(-30)
        }
    }
}

//MARK: - extension
extension UILabel{
    func asFont(rangeText: String, font: UIFont){
        guard let text = self.text else { return }
        
        let attributeString = NSMutableAttributedString(string: text)
        let range = (text as NSString).range(of: rangeText)
        attributeString.addAttribute(.font, value: font, range: range)
        self.attributedText = attributeString
    }
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
