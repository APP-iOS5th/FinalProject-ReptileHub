//
//  AddWeightView.swift
//  ReptileHub
//
//  Created by 이상민 on 9/4/24.
//

import UIKit

class AddWeightView: UIView {
    
    //MARK: - 날짜 선택 타이틀
    private lazy var addWeightDateTitle: UILabel = {
        let label = UILabel()
        label.text = "날짜"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.textFieldTitle
        return label
    }()
    
    //MARK: - 날짜 선택 픽커
    private lazy var addWeightDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        //        picker.backgroundColor = .red
        picker.preferredDatePickerStyle = .automatic
        picker.datePickerMode = .date
        return picker
    }()
    
    //MARK: - 몸무게 입력
    private lazy var addWeightTitle: UILabel = {
        let label = UILabel()
        label.text = "몸무게"
        return label
    }()
    
    //MARK: - 몸무게 텍스트필드
    private lazy var addWeightTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "몸무게를 입력해주세요."
        textField.keyboardType = .numberPad //숫자만 입력 가능하게 설정
        return textField
    }()
    
    //MARK: - 날씨 추가 스택 뷰
    private lazy var addWeightDateStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [addWeightDateTitle, addWeightDatePicker])
        view.axis = .horizontal
        return view
    }()
    
    //MARK: - 몸무게 추가 스택 뷰
    private lazy var addWeightStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [addWeightTextField, addWeightTextField])
        view.axis = .horizontal
        return view
    }()
    
    //MARK: - contentView
    private lazy var addWeightContentView: UIView = {
        let view = UIView()
        view.addSubview(addWeightDateStackView)
        view.addSubview(addWeightStackView)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUI(){
        self.addSubview(addWeightContentView)
        
        addWeightContentView.snp.makeConstraints { make in
            make.leading.equalTo(self).offset(Spacing.mainSpacing)
            make.trailing.equalTo(self).offset(-Spacing.mainSpacing)
            make.centerY.equalTo(self)
        }
        
        addWeightDateStackView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(addWeightContentView)
        }
        
        addWeightTitle.snp.makeConstraints { make in
            make.top.equalTo(addWeightDateStackView.snp.bottom).offset(20)
            make.leading.trailing.equalTo(addWeightContentView)
        }
        
        
    }
}


#if DEBUG
import SwiftUI

struct AddWeightViewRepresentable: UIViewRepresentable{
    func makeUIView(context: Context) -> AddWeightView {
        return AddWeightView()
    }
    
    func updateUIView(_ uiView: AddWeightView, context: Context) {
        uiView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}

#Preview(body: {
    AddWeightViewRepresentable()
})
#endif
