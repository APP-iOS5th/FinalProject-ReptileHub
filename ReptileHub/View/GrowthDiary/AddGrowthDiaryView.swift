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
        return label
    }
    
    private lazy var thumnailImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "tempImage")
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 5
        return view
    }()
    
    private lazy var inputTextField = { (placehoderText: String) -> UITextField in
        let textField = UITextField()
        textField.placeholder = placehoderText
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 5
        textField.layer.borderColor = CGColor(red: 215/255, green: 215/255, blue: 215/255, alpha: 1)
        textField.backgroundColor = UIColor(red: 215/255, green: 215/255, blue: 215/255, alpha: 0.5)
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 13, height: self.bounds.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        textField.rightView = paddingView
        textField.rightViewMode = .always
        return textField
    }
    
    private
    
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
        self.addSubview(thumnailImage)
        
        let nameTitle = titleLabel("이름이 어떻게 되나요?", "이름")
        self.addSubview(nameTitle)
        let nameTextField = inputTextField("바련 도마뱀의 이름을 입력해주세요")
        self.addSubview(nameTextField)
        
        let speciesTitle = titleLabel("종이 어떻게 되나요?", "종")
        self.addSubview(speciesTitle)
        let speciesTextField = inputTextField("반려 도마뱀의 종을 입력해주세요.")
        self.addSubview(speciesTextField)
        
        let morphTitle = titleLabel("모프 여부가 어떻게 되나요?", "모프 여부")
        self.addSubview(morphTitle)
        let morphTextField = inputTextField("모프를 입력해주세요.")
        self.addSubview(morphTextField)
        
        let hatchingTitle = titleLabel("해칭일이 어떻게 되나요?", "해칭일")
        self.addSubview(hatchingTitle)
        
        thumnailTitle.snp.makeConstraints { make in
            make.leading.equalTo(self).offset(Spacing.mainSpacing)
            make.trailing.equalTo(self).offset(-Spacing.mainSpacing)
        }
        thumnailImage.snp.makeConstraints { make in
            make.top.equalTo(thumnailTitle.snp.bottom).offset(10)
            make.leading.equalTo(self).offset(Spacing.mainSpacing)
            make.trailing.equalTo(self).offset(-Spacing.mainSpacing)
            make.height.equalTo(250) // 임시 높이
        }
        
        nameTitle.snp.makeConstraints { make in
            make.top.equalTo(thumnailImage.snp.bottom).offset(30)
            make.leading.equalTo(self).offset(Spacing.mainSpacing)
            make.trailing.equalTo(self).offset(-Spacing.mainSpacing)
        }
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(nameTitle.snp.bottom).offset(7)
            make.leading.equalTo(self).offset(Spacing.mainSpacing)
            make.trailing.equalTo(self).offset(-Spacing.mainSpacing)
            make.height.equalTo(45)
        }
        
        speciesTitle.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(30)
            make.leading.equalTo(self).offset(Spacing.mainSpacing)
            make.trailing.equalTo(self).offset(-Spacing.mainSpacing)
        }
        speciesTextField.snp.makeConstraints { make in
            make.top.equalTo(speciesTitle.snp.bottom).offset(7)
            make.leading.equalTo(self).offset(Spacing.mainSpacing)
            make.trailing.equalTo(self).offset(-Spacing.mainSpacing)
            make.height.equalTo(45)
        }
        
        morphTitle.snp.makeConstraints { make in
            make.top.equalTo(speciesTextField.snp.bottom).offset(30)
            make.leading.equalTo(self).offset(Spacing.mainSpacing)
            make.trailing.equalTo(self).offset(-Spacing.mainSpacing)
        }
        morphTextField.snp.makeConstraints { make in
            make.top.equalTo(morphTitle.snp.bottom).offset(7)
            make.leading.equalTo(self).offset(Spacing.mainSpacing)
            make.trailing.equalTo(self).offset(-Spacing.mainSpacing)
            make.height.equalTo(45)
        }
        
        hatchingTitle.snp.makeConstraints { make in
            make.top.equalTo(morphTextField.snp.bottom).offset(30)
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
