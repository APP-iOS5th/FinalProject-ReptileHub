//
//  AddWeightView.swift
//  ReptileHub
//
//  Created by 이상민 on 9/4/24.
//

import UIKit

class AddEditWeightView: UIView {
    
    // TODO: 델리게이트로 수정하기
    var cancelButtonTapped: (() -> Void)?
    var addButtonTapped: (() -> Void)?
    
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
        picker.preferredDatePickerStyle = .automatic
        picker.datePickerMode = .date
        return picker
    }()
    
    
    //MARK: - 날씨 추가 스택 뷰
    private lazy var addWeightDateStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [addWeightDateTitle, addWeightDatePicker])
        view.axis = .horizontal
        return view
    }()
    
    //MARK: - 몸무게 타이틀
    private lazy var addWeightTitle: UILabel = {
        let label = UILabel()
        label.text = "몸무게"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.textFieldTitle
        return label
    }()
    
    //MARK: - 몸무게 텍스트필드
    private lazy var addWeightTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "몸무게를 입력해주세요."
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.textColor = UIColor.textFieldPlaceholder
        textField.keyboardType = .numberPad //숫자만 입력 가능하게 설정
        textField.backgroundColor = UIColor.textFieldSegmentBG
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.textFieldBorderLine.cgColor
        textField.layer.cornerRadius = 5
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 13, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        textField.rightView = paddingView
        textField.rightViewMode = .always
        
        return textField
    }()
    
    //MARK: - 몸무게 추가 스택 뷰
    private lazy var addWeightStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [addWeightTitle, addWeightTextField])
        view.axis = .horizontal
        view.spacing = 20
        return view
    }()
    
    //MARK: - 취소 버튼
    private lazy var cancelAddWeight: UIButton = {
        let button = UIButton()
        
        var config = UIButton.Configuration.filled()
        config.title = "취소"
        config.baseForegroundColor = .white
        config.baseBackgroundColor = UIColor.imagePicker
        config.attributedTitle?.font = UIFont.systemFont(ofSize:20)
        button.configuration = config
        
        button.addAction(UIAction{ [weak self] _ in
            self?.cancelButtonTapped?()
        }, for: .touchUpInside)
        
        return button
    }()
    
    //MARK: - 등록 버튼
    private lazy var createAddWeight: UIButton = {
        let button = UIButton()
        
        var config = UIButton.Configuration.filled()
        config.title = "추가"
        config.baseForegroundColor = .white
        config.baseBackgroundColor = UIColor.addBtnGraphTabbar
        config.attributedTitle?.font = UIFont.systemFont(ofSize:20)
        button.configuration = config
        button.addAction(UIAction{ [weak self] _ in
            self?.addButtonTapped?()
        }, for: .touchUpInside)
        
        return button
    }()
    
    //MARK: - 취소/추가 버튼 스택 뷰
    private lazy var weightCancelCreateButtonStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [cancelAddWeight, createAddWeight])
        view.axis = .horizontal
        view.spacing = 20
        view.distribution = .fillEqually
        return view
    }()
    
    
    //MARK: - contentStackView
    private lazy var addWeightContentView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [addWeightDateStackView, addWeightStackView, weightCancelCreateButtonStackView])
        view.axis = .vertical
        view.spacing = 20
        return view
    }()
    
    //MARK: - mainView
    private lazy var mainView: UIView = {
        let view = UIView()
        view.addSubview(addWeightContentView)
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
        self.addSubview(mainView)
        
        mainView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addWeightContentView.snp.makeConstraints { make in
            make.leading.equalTo(self).offset(Spacing.mainSpacing)
            make.trailing.equalTo(self).offset(-Spacing.mainSpacing)
            make.centerY.equalTo(mainView)
        }
        
        addWeightDateStackView.snp.makeConstraints { make in
            make.leading.equalTo(addWeightContentView)
            make.trailing.equalTo(addWeightContentView)
        }
//        
        addWeightStackView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(addWeightContentView)
        }
//        
        addWeightTextField.snp.makeConstraints { make in
            make.height.equalTo(35)
        }
//        
        weightCancelCreateButtonStackView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(addWeightContentView)
        }
    }
    
    func addWeightRequest() -> (Int, Date){
        guard let weightText = self.addWeightTextField.text,
              let weight = Int(weightText)
        else {
            return (0, self.addWeightDatePicker.date)
        }
        return (weight, self.addWeightDatePicker.date)
    }
    
    func configureAddEditWeightView(weightData: WeightEntry){
        addWeightDatePicker.date = weightData.date
        addWeightTextField.text = String(weightData.weight)
        
        if var config = createAddWeight.configuration{
            config.title = "변경"
            createAddWeight.configuration = config
        }
    }
}


#if DEBUG
import SwiftUI

struct AddWeightViewRepresentable: UIViewRepresentable{
    func makeUIView(context: Context) -> AddEditWeightView {
        return AddEditWeightView()
    }
    
    func updateUIView(_ uiView: AddEditWeightView, context: Context) {
        uiView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}

#Preview(body: {
    AddWeightViewRepresentable()
})
#endif
