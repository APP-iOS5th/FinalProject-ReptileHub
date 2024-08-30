//
//  AddGrowthDiary.swift
//  ReptileHub
//
//  Created by 이상민 on 8/19/24.
//

import UIKit
import SnapKit

class AddGrowthDiaryView: UIView, UIGestureRecognizerDelegate, UITextFieldDelegate, UIScrollViewDelegate {
    
    //MARK: - 자식정보
    //이미지
    private(set) lazy var thumbnailImageView: UIImageView = createImageVIew()// TODO: ImagePicker로 구현
    //이름
    private lazy var nameTextField: UITextField = createTextField(text: "반려 도마뱀의 이름을 입력해주세요.")
    //종
    private lazy var speciesTextField: UITextField = createTextField(text: "반려 도마뱀의 종을 입력해주세요.")
    //모프
    private lazy var morphTextField: UITextField = createTextField(text: "모프를 입력해주세요.")
    //해칭일
    private lazy var hatchDaysDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .inline
        picker.datePickerMode = .date
        return picker
    }()
    private lazy var hatchDaysTextField: UITextField = {
        let textField = createTextField(text: "해칭일을 선택해주세요.")
        textField.inputView = hatchDaysDatePicker
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.setItems([doneButton], animated: true)
        textField.inputAccessoryView = toolbar
        
        return textField
    }()
    
    func addAction(action: UIAction){
        hatchDaysDatePicker.addAction(action, for: .valueChanged)
    }
    
    func updateDateField(){
        hatchDaysTextField.text = hatchDaysDatePicker.date.formatted
    }
    
    private func addTapGestureRecognizer() {
        // UITapGestureRecognizer 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutsideDropdown))
        tapGesture.cancelsTouchesInView = false // 다른 터치 이벤트와 충돌하지 않도록 설정
        tapGesture.delegate = self // 델리게이트 설정
        self.addGestureRecognizer(tapGesture)
    }
    
    // 드롭다운 외부를 터치했을 때 호출되는 메서드
    @objc private func handleTapOutsideDropdown(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        
        // 첫 번째 드롭다운 외부를 터치했을 때
        if genderDropdownView.isOpen && !genderDropdownView.frame.contains(location) {
            genderDropdownView.closeDropdown()
        }
        
        // 두 번째 드롭다운 외부를 터치했을 때
        if feedMethodDropdownView.isOpen && !feedMethodDropdownView.frame.contains(location) {
            feedMethodDropdownView.closeDropdown()
        }
        self.endEditing(true)
        
    }
    
    // UIGestureRecognizerDelegate 메서드: 드롭다운 내부의 터치 이벤트는 무시
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchedView = touch.view {
            if touchedView.isDescendant(of: genderDropdownView) {
                return false
            }
            if touchedView.isDescendant(of: feedMethodDropdownView) {
                return false
            }
        }
        return true
        
    }
    
    
    //성별
    private lazy var genderDropdownView = DropDownView(options: ["수컷", "암컷", "기타"], title: "성별을 선택해주세요.")
    //무게
    private lazy var weightTextField: UITextField = createTextField(text: "무게를 입력해주세요.")
    //피딩 방식
    private lazy var feedMethodDropdownView: DropDownView = DropDownView(options: ["자율", "핸드"], title: "피딩 방식을 선택해주세요.")
    //꼬리 유무
    private lazy var tailButtonGroup: UIView = createButtonGroup(
        title: "꼬리",
        buttonTitles: ("있음", "없음")
    )
    //    private lazy var hatchDaysDatePicker: UIDatePicker = {
    //        let picker = UIDatePicker()
    //        picker.preferredDatePickerStyle = .wheels
    //        picker.datePickerMode = .date
    //        picker.addTarget(self, action: #selector(dateChange), for: .valueChanged)
    //        return picker
    //    }()
    //
    //    //해칭일 날짜 textField
    //    private lazy var hatchDaysTextFiled: UITextField = {
    //        let textField = createTextField(text: Date().toString())
    //        textField.inputView = hatchDaysDatePicker
    //        return textField
    //    }()
    
    
    // 텍스트 필드에 들어갈 텍스트를 DateFormatter 변환
    //    private func dateFormat(date: Date) -> String {
    //        let formatter = DateFormatter()
    //        formatter.dateFormat = "yyyy / MM / dd"
    //
    //        return formatter.string(from: date)
    //    }
    //MARK: - 아빠 정보
    //아빠 이미지
    private(set) lazy var fatherImageView: UIImageView = createImageVIew()
    //아빠 이름
    private lazy var fatherNameTextField: UITextField = createTextField(text: "이름을 입력해주세요.")
    //아빠 모프
    private lazy var fatherMorphTextField: UITextField = createTextField(text: "무게를 입력해주세요.")
    
    //MARK: - 엄마 정보
    //엄마 이미지
    private(set) lazy var motherImageView: UIImageView = createImageVIew()
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
            createGroup(title: "해칭일이 어떻게 되나요?", contentView: hatchDaysTextField),
            //            createTextFieldGroup(title: "성별이 어떻게 되나요?", textField: genderTextField),
            createGroup(title: "성별이 어떻게 되나요?", contentView: genderDropdownView),
            createTextFieldGroup(title: "무게가 어떻게 되나요?", textField: weightTextField),
            //            createTextFieldGroup(title: "피딩 방식이 어떻게 되나요?", textField: feedMethodTextField),
            createGroup(title: "피딩 방식이 어떻게 되나요?", contentView: feedMethodDropdownView),
            tailButtonGroup,
            createShowGroupViewButton(title: "부모 정보가 어떻게 되나요?", contentView: parentInfoStackView, buttonTitles: ("등록", "미등록")),
            
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
        scrollView.delegate = self
        return scrollView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        addTapGestureRecognizer()
        configureTextFields()
        registerForKeyboardNotifications()
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
    
    @objc private func doneButtonTapped(){
        UIView.animate(withDuration: 0.3) {
            self.hatchDaysTextField.resignFirstResponder()
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
        imageView.image = UIImage(systemName: "plus")
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        imageView.layer.cornerRadius = 10
        imageView.isUserInteractionEnabled = true //제스터를 인식하기위해 설정
        
        imageView.snp.makeConstraints { make in
            make.height.equalTo(250)
        }
        return imageView
    }
    
    // 이미지뷰에 제스처를 추가하는 메서드
    func configureImageViewActions(target: Any, action: Selector) {
        [thumbnailImageView, fatherImageView, motherImageView].forEach { imageView in
            let tapGesture = UITapGestureRecognizer(target: target, action: action)
            imageView.addGestureRecognizer(tapGesture)
        }
    }
    
    // 특정 이미지뷰에 이미지를 설정하는 메서드
    func setImage(_ image: UIImage, for imageView: UIImageView) {
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
    }
    
    //button 생성
    private func createButton(title: String) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        
        var ButtonText = AttributedString(title)
        
        var Attributes = AttributeContainer()
        Attributes.font = UIFont.systemFont(ofSize: 14)
        ButtonText.mergeAttributes(Attributes)
        config.attributedTitle = ButtonText
        
        config.baseBackgroundColor = UIColor(cgColor: CGColor(red: 215/255, green: 215/255, blue: 215/255, alpha: 0.5))
        config.baseForegroundColor = .black
        config.cornerStyle = .medium // 모서리 둥글게 설정
        
        let button = UIButton(configuration: config)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
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
    private func createShowGroupViewButton(title: String, contentView: UIView, buttonTitles: (String ,String)) -> UIView {
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
        showConfig.baseBackgroundColor = .systemBlue
        showConfig.baseForegroundColor = .white
        
        showButton.configuration = showConfig
        
        //MARK: - 없음/미등록 버튼
        let hideButton = UIButton()
        var hideConfig = UIButton.Configuration.filled()
        var hideButtonText = AttributedString(buttonTitles.1)
        
        var hideAttributes = AttributeContainer()
        hideAttributes.font = UIFont.systemFont(ofSize: 14)
        hideButtonText.mergeAttributes(hideAttributes)
        hideConfig.attributedTitle = hideButtonText
        hideConfig.attributedTitle = hideButtonText
        hideConfig.baseBackgroundColor = UIColor(cgColor: CGColor(red: 215/255, green: 215/255, blue: 215/255, alpha: 0.5))
        hideConfig.baseForegroundColor = .black
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
        
        contentView.isHidden = false
        
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
        
        // 초기 상태에서 첫 번째 버튼을 활성화된 상태로 설정
        firstButton.isSelected = true
        updateButtonSelection(firstButton, secondButton) // 초기 상태 설정
        
        firstButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        secondButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        return createGroup(title: title, contentView: buttonStackView)
    }
    private func updateButtonSelection(_ firstButton: UIButton, _ secondButton: UIButton) {
        // 첫 번째 버튼
        if firstButton.isSelected {
            var config = firstButton.configuration ?? UIButton.Configuration.filled()
            config.baseBackgroundColor = .systemBlue
            config.baseForegroundColor = .white
            firstButton.configuration = config
        } else {
            var config = firstButton.configuration ?? UIButton.Configuration.filled()
            config.baseBackgroundColor = UIColor(cgColor: CGColor(red: 215/255, green: 215/255, blue: 215/255, alpha: 0.5))
            config.baseForegroundColor = .black
            firstButton.configuration = config
        }
        
        // 두 번째 버튼
        if secondButton.isSelected {
            var config = secondButton.configuration ?? UIButton.Configuration.filled()
            config.baseBackgroundColor = .systemBlue
            config.baseForegroundColor = .white
            secondButton.configuration = config
        } else {
            var config = secondButton.configuration ?? UIButton.Configuration.filled()
            config.baseBackgroundColor = UIColor(cgColor: CGColor(red: 215/255, green: 215/255, blue: 215/255, alpha: 0.5))
            config.baseForegroundColor = .black
            secondButton.configuration = config
        }
    }
    
    //MARK: - Action
    
    @objc private func buttonTapped(_ sender: UIButton) {
        guard let buttonStackView = sender.superview as? UIStackView else { return }
        
        let firstButton = buttonStackView.arrangedSubviews[0] as! UIButton
        let secondButton = buttonStackView.arrangedSubviews[1] as! UIButton
        
        if sender == firstButton {
            firstButton.isSelected = true
            secondButton.isSelected = false
        } else {
            firstButton.isSelected = false
            secondButton.isSelected = true
        }
        
        updateButtonSelection(firstButton, secondButton)
    }
    
    
    @objc private func showContent(_ sender: UIButton) {
        if let stackView = sender.superview?.superview as? UIStackView,
           let contentView = stackView.arrangedSubviews.last,
           let buttonStackView = stackView.arrangedSubviews[1] as? UIStackView,
           let showButton = buttonStackView.arrangedSubviews[0] as? UIButton,
           let hideButton = buttonStackView.arrangedSubviews[1] as? UIButton {
            
            UIView.animate(withDuration: 0.2) {
                contentView.isHidden = false
            }
            
            // showButton을 선택 상태로 설정
            showButton.configuration?.baseBackgroundColor = .systemBlue
            showButton.configuration?.baseForegroundColor = .white
            
            // hideButton을 기본 상태로 설정
            hideButton.configuration?.baseBackgroundColor = UIColor(cgColor: CGColor(red: 215/255, green: 215/255, blue: 215/255, alpha: 0.5))
            hideButton.configuration?.baseForegroundColor = .black
        }
    }
    
    @objc private func hideContent(_ sender: UIButton) {
        if let stackView = sender.superview?.superview as? UIStackView,
           let contentView = stackView.arrangedSubviews.last,
           let buttonStackView = stackView.arrangedSubviews[1] as? UIStackView,
           let showButton = buttonStackView.arrangedSubviews[0] as? UIButton,
           let hideButton = buttonStackView.arrangedSubviews[1] as? UIButton {
            
            UIView.animate(withDuration: 0.2) {
                contentView.isHidden = true
            }
            
            // hideButton을 선택 상태로 설정
            hideButton.configuration?.baseBackgroundColor = .systemBlue
            hideButton.configuration?.baseForegroundColor = .white
            
            // showButton을 기본 상태로 설정
            showButton.configuration?.baseBackgroundColor = UIColor(cgColor: CGColor(red: 215/255, green: 215/255, blue: 215/255, alpha: 0.5))
            showButton.configuration?.baseForegroundColor = .black
        }
    }
    private func configureTextFields() {
        nameTextField.delegate = self
        speciesTextField.delegate = self
        morphTextField.delegate = self
        hatchDaysTextField.delegate = self
        weightTextField.delegate = self
        fatherNameTextField.delegate = self
        fatherMorphTextField.delegate = self
        motherNameTextField.delegate = self
        motherMorphTextField.delegate = self
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        genderDropdownView.closeDropdownOnScroll()
        feedMethodDropdownView.closeDropdownOnScroll()
    }
    
    // UITextFieldDelegate 메서드: Return 키를 눌렀을 때 키보드 닫기
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // 키보드를 닫음
        return true
    }
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    private func findFirstResponder(in view: UIView) -> UIView? {
        for subview in view.subviews {
            if subview.isFirstResponder {
                return subview
            }
            if let recursiveSubview = findFirstResponder(in: subview) {
                return recursiveSubview
            }
        }
        return nil
    }
    
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            // 현재 스크롤 뷰의 기존 contentInset을 가져와서 조정
            var contentInset = scrollView.contentInset
            contentInset.bottom = keyboardHeight
            scrollView.contentInset = contentInset
            scrollView.verticalScrollIndicatorInsets = contentInset
            
            // 현재 활성화된 텍스트 필드가 있는 경우, 그것이 가려지지 않도록 스크롤
            if let activeField = findFirstResponder(in: self) {
                let visibleRect = self.bounds.inset(by: scrollView.contentInset)
                let activeFieldFrame = activeField.convert(activeField.bounds, to: self)
                
                if !visibleRect.contains(activeFieldFrame) {
                    scrollView.scrollRectToVisible(activeFieldFrame, animated: true)
                }
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        // 키보드가 내려갈 때, 스크롤뷰의 인셋을 원래대로 돌려놓음
        let contentInset = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
        scrollView.verticalScrollIndicatorInsets = contentInset
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
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
