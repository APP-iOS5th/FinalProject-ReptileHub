//
//  AddGrowthDiary.swift
//  ReptileHub
//
//  Created by 이상민 on 8/19/24.
//

import UIKit
import SnapKit

class AddGrowthDiaryView: UIView, UIGestureRecognizerDelegate, UITextFieldDelegate, UIScrollViewDelegate, KeyboardNotificationDelegate {

    typealias request = (GrowthDiaryRequest, [Data?])
    
    var buttonTapped: (()->Void)?
    let keyboardManager = KeyboardManager()
    private var morphSelected = false
    private var tailSelected = true
    private var parentSelected = true
    
    //MARK: - 자식정보
    //이미지
    private(set) lazy var thumbnailImageView: UIImageView = createImageVIew()
    //이름
    private lazy var nameTextField: UITextField = createTextField(text: "반려 도마뱀의 이름을 입력해주세요.")
    //종
    private lazy var speciesTextField: UITextField = createTextField(text: "반려 도마뱀의 종을 입력해주세요.")
    //모프
    private lazy var morphTextField: UITextField = createTextField(text: "모프를 입력해주세요.")
    private lazy var morphChoice = createShowGroupViewButton(title: "모프 여부가 어떻게 되나요?", contentView: morphTextField, buttonTitles: ("있음", "없음"))
    //해칭일
    private lazy var hatchDaysDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .inline
        picker.datePickerMode = .date
        picker.setDate(Date(), animated: true)
        return picker
    }()
    private lazy var hatchDaysTextField: UITextField = {
        let textField = createTextField(text: "해칭일을 선택해주세요.")
        textField.inputView = hatchDaysDatePicker
        textField.textColor = UIColor.textFieldTitle
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
    private lazy var genderDropdownView = DropDownView(options: [Gender.male.rawValue, Gender.female.rawValue, Gender.unKnown.rawValue], title: "성별을 선택해주세요.")
    //무게
    private lazy var weightTextField: UITextField = createTextField(text: "무게를 입력해주세요.")
    //피딩 방식
    private lazy var feedMethodDropdownView: DropDownView = DropDownView(options: ["자율", "핸드"], title: "피딩 방식을 선택해주세요.")
    //꼬리 유무
    private lazy var tailButtonGroup: UIView = createButtonGroup(
        title: "꼬리",
        buttonTitles: ("있음", "없음")
    )
    
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
        view.backgroundColor = UIColor.textFieldBorderLine
        return view
    }()
    //엄마, 아빠정보 스택 뷰
    private lazy var parentInfoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            createParentInfoSubGroup(title: "아빠 도마뱀", imageView: fatherImageView, nameTextField: fatherNameTextField, morphTextField: fatherMorphTextField),
            line,
            createParentInfoSubGroup(title: "엄마 도마뱀", imageView: motherImageView, nameTextField: motherNameTextField, morphTextField: motherMorphTextField)
        ])
        stackView.backgroundColor = UIColor.groupProfileBG
        stackView.axis = .vertical
        stackView.layer.cornerRadius = 10
        stackView.spacing = 20
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        return stackView
    }()
    
    //MARK: - 성장일지 등록버튼
    private lazy var uploadGrowthDiaryButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        
        var config = UIButton.Configuration.filled()
        
        //AttributedString 설정
        var buttonText = AttributedString("등록하기") //텍스트 정의
        
        //AttributeContainer 생성 및 폰트, 색상 설정
        var attributes = AttributeContainer()
        attributes.font = UIFont.systemFont(ofSize: 18, weight: .semibold) //폰트크기 설정
        
        //AttributedString에 속성 적용
        buttonText.mergeAttributes(attributes)
        
        config.attributedTitle = buttonText
        config.baseBackgroundColor = UIColor.addBtnGraphTabbar
        config.baseForegroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 0, bottom: 14, trailing: 0)
        button.configuration = config
        
        button.addAction(UIAction{ [weak self] _ in
            self?.buttonTapped?() //클로저가 실행된다.
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            createThumbnailGroup(),
            createTextFieldGroup(title: "이름이 어떻게 되나요?", textField: nameTextField),
            createTextFieldGroup(title: "종이 어떻게 되나요?", textField: speciesTextField),
            morphChoice,
            createGroup(title: "해칭일이 어떻게 되나요?", contentView: hatchDaysTextField),
            //            createTextFieldGroup(title: "성별이 어떻게 되나요?", textField: genderTextField),
            createGroup(title: "성별이 어떻게 되나요?", contentView: genderDropdownView),
            createTextFieldGroup(title: "무게가 어떻게 되나요?", textField: weightTextField),
            //            createTextFieldGroup(title: "피딩 방식이 어떻게 되나요?", textField: feedMethodTextField),
            createGroup(title: "피딩 방식이 어떻게 되나요?", contentView: feedMethodDropdownView),
            tailButtonGroup,
            createShowGroupViewButton(title: "부모 정보가 어떻게 되나요?", contentView: parentInfoStackView, buttonTitles: ("등록", "미등록")),
            uploadGrowthDiaryButton
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
        keyboardManager.showNoti()
        keyboardManager.hideNoti()
        keyboardManager.delegate = self
//        registerForKeyboardNotifications()
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
            make.leading.trailing.equalTo(scrollView)
            make.top.equalTo(scrollView).offset(30)
            make.bottom.equalTo(scrollView).offset(-30)
            make.width.equalTo(scrollView)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalTo(scrollView).inset(Spacing.mainSpacing)
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
        textField.attributedPlaceholder = NSAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor : UIColor.textFieldPlaceholder])
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = UIColor.textFieldTitle
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 5
        textField.layer.borderColor = UIColor.textFieldLine.cgColor
        textField.backgroundColor = UIColor.textFieldSegmentBG
        
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
        imageView.image = UIImage(systemName: "plus")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor.textFieldPlaceholder
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.imagePicker
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = UIColor.imagePicker.cgColor
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
        
        config.baseBackgroundColor = UIColor.textFieldSegmentBG
        config.baseForegroundColor = UIColor.textFieldPlaceholder
        config.cornerStyle = .medium // 모서리 둥글게 설정
        
        let button = UIButton(configuration: config)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.textFieldBorderLine.cgColor
        
        return button
    }
    
    //그룹 만들기 함수(라벨 + uiview)
    private func createGroup(title: String, contentView: UIView) -> UIView{
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.textColor = UIColor.textFieldTitle
        
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
        label.textColor = UIColor.textFieldTitle
        
        //MARK: - 있음/등록 버튼
        let showButton = UIButton()
        var showConfig = UIButton.Configuration.filled()
        var showButtonText = AttributedString(buttonTitles.0)
        
        var showAttributes = AttributeContainer()
        showAttributes.font = UIFont.systemFont(ofSize: 14)
        showButtonText.mergeAttributes(showAttributes)
        showConfig.attributedTitle = showButtonText
        showConfig.baseBackgroundColor = UIColor.textFieldLine
        showConfig.baseForegroundColor = UIColor.textFieldTitle
        
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
        hideConfig.baseBackgroundColor = UIColor.textFieldSegmentBG
        hideConfig.baseForegroundColor = UIColor.textFieldPlaceholder
        hideButton.configuration = hideConfig
        hideButton.tag = 2
        
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
            tailSelected = true
            var config = firstButton.configuration ?? UIButton.Configuration.filled()
            config.baseBackgroundColor = UIColor.booleanButton
            config.baseForegroundColor = .white
            firstButton.configuration = config
        } else {
            var config = firstButton.configuration ?? UIButton.Configuration.filled()
            config.baseBackgroundColor = UIColor.textFieldSegmentBG
            config.baseForegroundColor = UIColor.textFieldPlaceholder
            firstButton.configuration = config
        }
        
        // 두 번째 버튼
        if secondButton.isSelected {
            tailSelected = false
            var config = secondButton.configuration ?? UIButton.Configuration.filled()
            config.baseBackgroundColor = UIColor.booleanButton
            config.baseForegroundColor = .white
            secondButton.configuration = config
        } else {
            var config = secondButton.configuration ?? UIButton.Configuration.filled()
            config.baseBackgroundColor = UIColor.textFieldSegmentBG
            config.baseForegroundColor = UIColor.textFieldPlaceholder
            secondButton.configuration = config
        }
    }
    
    func growthDiaryRequestData() -> request{
        let lizardInfo = LizardInfo(name: nameTextField.text ?? "이름 없음", species: speciesTextField.text ?? "종 없음", morph: morphTextField.text, hatchDays: hatchDaysDatePicker.date, gender: Gender(rawValue: genderDropdownView.selectedOption!)!, weight: Int(weightTextField.text ?? "0")!, feedMethod: feedMethodDropdownView.selectedOption!, tailexistence: tailSelected)
        var imageData: [Data?] = [thumbnailImageView.image?.pngData()]
        if parentSelected{
            let mother = ParentInfo(name: motherNameTextField.text ?? "이름 없음", morph: motherMorphTextField.text)
            imageData.append(motherImageView.image == nil ? nil : motherImageView.image?.pngData())
            let father = ParentInfo(name: fatherNameTextField.text ?? "이름 없음", morph: fatherMorphTextField.text)
            imageData.append(fatherImageView.image == nil ? nil : fatherImageView.image?.pngData())
            let parent = Parents(mother: mother, father: father)
            return (GrowthDiaryRequest(lizardInfo: lizardInfo, parentInfo: parent),imageData)
        }
        imageData.append(contentsOf: [nil, nil])
        return (GrowthDiaryRequest(lizardInfo: lizardInfo, parentInfo: nil), imageData)
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
            if showButton.layer.name == "있음"{
                self.morphSelected = true
                print(morphSelected)
            }else{
                self.parentSelected = true
                print(parentSelected)
            }
            
            
            // showButton을 선택 상태로 설정
            showButton.configuration?.baseBackgroundColor = UIColor.textFieldLine
            showButton.configuration?.baseForegroundColor = UIColor.textFieldTitle
            
            // hideButton을 기본 상태로 설정
            hideButton.configuration?.baseBackgroundColor = UIColor.textFieldSegmentBG
            hideButton.configuration?.baseForegroundColor = UIColor.textFieldPlaceholder
        }
    }
    
    @objc private func hideContent(_ sender: UIButton) {
        if let stackView = sender.superview?.superview as? UIStackView,
           let contentView = stackView.arrangedSubviews.last,
           let buttonStackView = stackView.arrangedSubviews[1] as? UIStackView,
           let showButton = buttonStackView.arrangedSubviews[0] as? UIButton,
           let hideButton = buttonStackView.arrangedSubviews[1] as? UIButton {
            
            if hideButton.layer.name == "없음"{
                self.morphSelected = false
            }else{
                self.parentSelected = false
            }
            
            UIView.animate(withDuration: 0.2) {
                contentView.isHidden = true
            }
            morphSelected = false
            // hideButton을 선택 상태로 설정
            hideButton.configuration?.baseBackgroundColor = UIColor.textFieldLine
            hideButton.configuration?.baseForegroundColor = UIColor.textFieldTitle
            
            // showButton을 기본 상태로 설정
            showButton.configuration?.baseBackgroundColor = UIColor.textFieldSegmentBG
            showButton.configuration?.baseForegroundColor = UIColor.textFieldPlaceholder
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
    
    func keyboardWillShow(keyboardSize: CGRect) {
        scrollView.snp.updateConstraints { make in
            make.bottom.equalToSuperview().offset(-keyboardSize.height)
        }
        self.layoutIfNeeded()
    }
    
    func keyboardWillHide(keyboardSize: CGRect) {
        scrollView.snp.updateConstraints { make in
            make.bottom.equalToSuperview()
        }
        self.layoutIfNeeded()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == hatchDaysTextField && textField.text?.isEmpty ?? true{
            let datePicker = textField.inputView as? UIDatePicker
            textField.text = datePicker?.date.formatted
        }
    }
    
    func configureEditGrowthDiary(configureData: GrowthDiaryResponse){
        print("여기얌~~", configureData)
        let lizardInfo = configureData.lizardInfo
        //자식 이미지
        if let lizardImageName = lizardInfo.imageURL{
            thumbnailImageView.setImage(with: lizardImageName)
        }
        nameTextField.text = lizardInfo.name
        speciesTextField.text = lizardInfo.species
        
        if let morph = lizardInfo.morph{
            morphTextField.text = morph
        }
        
        hatchDaysTextField.text = lizardInfo.hatchDays.formatted
        
        genderDropdownView.selectedOption = lizardInfo.gender
        
        weightTextField.text = String(lizardInfo.weight)
        
        feedMethodDropdownView.selectedOption = lizardInfo.feedMethod
        
        tailSelected = lizardInfo.tailexistence
        
        guard let parentInfo = configureData.parentInfo else {
            return
        }
       
        if let fatherImageName = parentInfo.father.imageURL{
            fatherImageView.setImage(with: fatherImageName)
        }
        
        fatherNameTextField.text = parentInfo.father.name
        
        if let fatherMorph = parentInfo.father.morph{
            fatherMorphTextField.text = fatherMorph
        }
        
        if let motherImageName = parentInfo.father.imageURL{
            motherImageView.setImage(with: motherImageName)
        }
        
        motherNameTextField.text = parentInfo.father.name
        
        if let motherMorph = parentInfo.father.morph{
            motherMorphTextField.text = motherMorph
        }
        
        if var config = uploadGrowthDiaryButton.configuration{
            config.title = "수정하기"
            uploadGrowthDiaryButton.configuration = config
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
