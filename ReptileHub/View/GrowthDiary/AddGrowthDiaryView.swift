//
//  AddGrowthDiary.swift
//  ReptileHub
//
//  Created by 이상민 on 8/19/24.
//

import UIKit
import SnapKit

class AddGrowthDiaryView: UIView {
    
    //MARK: - 자식정보
    //이미지
    private lazy var thumbnailImageView: UIView = createImageVIew()// TODO: ImagePicker로 구현
    //이름
    private lazy var nameTextField: UITextField = createTextField(text: "반려 도마뱀의 이름을 입력해주세요.")
    //종
    private lazy var speciesTextField: UITextField = createTextField(text: "반려 도마뱀의 종을 입력해주세요.")
    //모프
    private lazy var morphTextField: UITextField = createTextField(text: "모프를 입력해주세요.")
    //해칭일
    private lazy var hatchDaysTextField: UITextField = createTextField(text: "2024.08.05")
    //성별
    private lazy var genderTextField: UITextField = createTextField(text: "성별을 선택해주세요")// TODO: 드롭다운으로 구현
    //무게
    private lazy var weightTextField: UITextField = createTextField(text: "무게를 입력해주세요.")
    //피딩 방식
    private lazy var feedMethodTextField: UITextField = createTextField(text: "피딩 방식을 선택해주세요.") // TODO: 드롭다운으로 구현
    //꼬리 유무
    private lazy var tailButtonGroup: UIView = createButtonGroup(
        title: "꼬리",
        buttonTitles: ("보기", "닫기")
    )
    
    //MARK: - 아빠 정보
    //아빠 이미지
    private lazy var fatherImageView: UIImageView = createImageVIew()
    //아빠 이름
    private lazy var fatherNameTextField: UITextField = createTextField(text: "이름을 입력해주세요.")
    //아빠 모프
    private lazy var fatherMorphTextField: UITextField = createTextField(text: "무게를 입력해주세요.")
    
    //MARK: - 엄마 정보
    //엄마 이미지
    private lazy var motherImageView: UIImageView = createImageVIew()
    //엄마 이름
    private lazy var motherNameTextField: UITextField = createTextField(text: "이름을 입력해주세요.")
    //엄마 모프
    private lazy var motherMorphTextField: UITextField = createTextField(text: "무게를 입력해주세요.")
    
    //MARK: - 부모 뷰
    //구분선
    private lazy var line: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    //엄마, 아빠정보 스택 뷰
    private lazy var parentInfoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            createParentInfoSubGroup(title: "아빠 도마뱀", imageView: fatherImageView, nameTextField: fatherNameTextField, morphTextField: fatherMorphTextField),
            line,
            createParentInfoSubGroup(title: "엄마 도마뱀", imageView: motherImageView, nameTextField: motherNameTextField, morphTextField: motherMorphTextField)
        ])
        stackView.backgroundColor = .lightGray
        stackView.axis = .vertical
        stackView.layer.cornerRadius = 10
        stackView.spacing = 20
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        return stackView
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            createThumbnailGroup(),
            createTextFieldGroup(title: "이름이 어떻게 되나요?", textField: nameTextField),
            createTextFieldGroup(title: "종이 어떻게 되나요?", textField: speciesTextField),
            createShowGroupViewButton(title: "모프 여부가 어떻게 되나요?", contentView: morphTextField, buttonTitles: ("있음", "없음")),
            createTextFieldGroup(title: "해칭일이 어떻게 되나요?", textField: hatchDaysTextField),
            createTextFieldGroup(title: "성별이 어떻게 되나요?", textField: genderTextField),
            createTextFieldGroup(title: "무게가 어떻게 되나요?", textField: weightTextField),
            createTextFieldGroup(title: "피딩 방식이 어떻게 되나요?", textField: feedMethodTextField),
            tailButtonGroup,
            createShowGroupViewButton(title: "부모 정보가 어떻게 되나요?", contentView: parentInfoStackView, buttonTitles: ("등록", "미등록"))
            
        ])
        stackView.axis = .vertical
        stackView.spacing = 20
        return stackView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        return scrollView
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
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainStackView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalTo(scrollView).inset(24)
        }
        
        line.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
    }
    
    //MARK: - Helper Methods
    //TextField 생성
    private func createTextField(text: String) -> UITextField{
        let textField = UITextField()
        textField.placeholder = text
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 5
        textField.layer.borderColor = CGColor(red: 215/255, green: 215/255, blue: 215/255, alpha: 1)
        textField.backgroundColor = UIColor(red: 215/255, green: 215/255, blue: 215/255, alpha: 0.5)
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 13, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        textField.rightView = paddingView
        textField.rightViewMode = .always
        
        textField.snp.makeConstraints { make in
            make.height.equalTo(45)
        }
        
        return textField
    }
    
    //ImageView 생성
    private func createImageVIew() -> UIImageView{
        let imageView = UIImageView()
        // TODO: 추후 이미지 선택으로 바꿔야함
        imageView.image = UIImage(named: "tempImage")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.snp.makeConstraints { make in
            make.height.equalTo(250)
        }
        return imageView
    }
    
    //button 생성
    private func createButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        return button
    }
    
    //그룹 만들기 함수(라벨 + uiview)
    private func createGroup(title: String, contentView: UIView) -> UIView{
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, contentView])
        stackView.axis = .vertical
        stackView.spacing = 10
        
        return stackView
    }
    
    //썸네일 그룹
    private func createThumbnailGroup() -> UIView{
        return createGroup(title: "썸네일", contentView: thumbnailImageView)
    }
    
    //텍스트필드 그룹
    private func createTextFieldGroup(title: String, textField: UITextField) -> UIView{
        return createGroup(title: title, contentView: textField)
    }
    
    //각 부모 정보입력 그룹
    private func createParentInfoSubGroup(title: String, imageView: UIImageView, nameTextField: UITextField, morphTextField: UITextField) -> UIView{
        let parentNameGroup = createGroup(title: "이름", contentView: nameTextField)
        let parentMorphGroup = createGroup(title: "모프", contentView: morphTextField)
        let stackView = UIStackView(arrangedSubviews: [imageView, parentNameGroup, parentMorphGroup])
        stackView.axis = .vertical
        stackView.spacing = 20
        return createGroup(title: title, contentView: stackView)
    }
    
    //부모 정보 그룹
    private func createParentInfoGroup() -> UIView{
        return createGroup(title: "부모 정보가 어떻게 되나요?", contentView: parentInfoStackView)
    }
    
    //버튼으로 contentview가 보이는 그룹
    private func createShowGroupViewButton(title: String, contentView: UIView, buttonTitles: (String,String)) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 20)
        
        //MARK: - 있음/등록 버튼
        let showButton = UIButton()
        var showConfig = UIButton.Configuration.filled()
        var showButtonText = AttributedString(buttonTitles.0)
        
        var showAttributes = AttributeContainer()
        showAttributes.font = UIFont.systemFont(ofSize: 14)
        showButtonText.mergeAttributes(showAttributes)
        showConfig.attributedTitle = showButtonText
        showButton.configuration = showConfig
        
        //MARK: - 없음/미등록 버튼
        let hideButton = UIButton()
        var hideConfig = UIButton.Configuration.filled()
        
        var hideButtonText = AttributedString(buttonTitles.1)
        
        var hideAttributes = AttributeContainer()
        hideAttributes.font = UIFont.systemFont(ofSize: 14)
        hideButtonText.mergeAttributes(hideAttributes)
        hideConfig.attributedTitle = hideButtonText
        hideButton.configuration = hideConfig
        
        let buttonStackView = UIStackView(arrangedSubviews: [showButton, hideButton])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 20
        
        let sectionStackView = UIStackView(arrangedSubviews: [label, buttonStackView, contentView])
        sectionStackView.axis = .vertical
        sectionStackView.spacing = 10
        
        let sectionView = UIView()
        sectionView.addSubview(sectionStackView)
        sectionStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.isHidden = true
        
        showButton.addTarget(self, action: #selector(showContent(_:)), for: .touchUpInside)
        hideButton.addTarget(self, action: #selector(hideContent(_:)), for: .touchUpInside)
        
        return sectionView
    }
    
    //버튼 그룹(라벨 + 버튼)
    private func createButtonGroup(title: String, buttonTitles: (String, String)) -> UIView {
        let firstButton = createButton(title: buttonTitles.0)
        let secondButton = createButton(title: buttonTitles.1)
        
        let buttonStackView = UIStackView(arrangedSubviews: [firstButton, secondButton])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 20
        buttonStackView.distribution = .fillEqually
        
        return createGroup(title: title, contentView: buttonStackView)
    }
    
    
    //MARK: - Action
    @objc private func showContent(_ sender: UIButton) {
        if let stackView = sender.superview?.superview as? UIStackView, let contentView = stackView.arrangedSubviews.last {
            UIView.animate(withDuration: 0.2) {
                contentView.isHidden = false
            }
        }
    }
    
    @objc private func hideContent(_ sender: UIButton) {
        if let stackView = sender.superview?.superview as? UIStackView, let contentView = stackView.arrangedSubviews.last {
            UIView.animate(withDuration: 0.2) {
                contentView.isHidden = true
            }
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
