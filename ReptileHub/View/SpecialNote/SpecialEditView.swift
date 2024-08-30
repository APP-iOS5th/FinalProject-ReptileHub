//
//  SpecialEditView.swift
//  ReptileHub
//
//  Created by 황민경 on 8/26/24.
//

import UIKit
import SnapKit
import PhotosUI

protocol SpecialEditViewDelegate: AnyObject {
    func didTapPostButton(imageData: [Data], title: String, content: String)
}

class SpecialEditView: UIView {
    
    weak var delegate: SpecialEditViewDelegate?
    
    override init(frame: CGRect) {
        super .init(frame: .zero)
        
        // 제스처 적용(슈퍼뷰 클릭시 키보드 내려감)
        self.addGestureRecognizer(tapGesture)
        keyboardManager.delegate = self
        keyboardManager.showNoti()
        keyboardManager.hideNoti()
        selectedImages.removeAll()
        imageData.removeAll()
        setupImagePickerCollectionView()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - 키보드 탭 제스쳐
    lazy var tapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        tap.cancelsTouchesInView = false // 터치 이벤트를 취소하지 않도록 설정
        return tap
    }()
    
    let keyboardManager = KeyboardManager()
    // super view 클릭시 키보드 내려감
    @objc
    func tapHandler(_ sender: UIView) {
        specialTitle.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
    }
    //MARK: - 이미지 선택 버튼 - CollectionView, PHPickerView
    // PhPicker에서 선택한 이미지들
    var selectedImages: [UIImage?] = []
    
    // selectedImages의 데이터화 배열
    var imageData: [Data] = []
    // 이미지 선택 CollectionView
    var imagePickerCollectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    var picker: PHPickerViewController = PHPickerViewController(configuration: PHPickerConfiguration())
    
    //MARK: - 날짜 (datePicker로 수정)
    private lazy var dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.text = "날짜"
        dateLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        dateLabel.textColor = .lightGray
        return dateLabel
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
//        datePicker.backgroundColor = UIColor(named: "Light_Green")
        datePicker.tintColor = UIColor(named: "datePickerBG")
//        datePicker.layer.cornerRadius = 5
        datePicker.preferredDatePickerStyle = .automatic
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ko-KR")
        datePicker.timeZone = .autoupdatingCurrent
        datePicker.addTarget(self, action: #selector(handleDatePicker(_:)), for: .valueChanged)
        return datePicker
    }()
    
    // MARK: DatePicker Selectors
    @objc
    private func handleDatePicker(_ sender: UIDatePicker) {
        print(sender.date)
    }
    
    //MARK: - 제목 입력
    private lazy var specialTitle: UITextField = {
        let specialTitle = UITextField()
        specialTitle.placeholder = "제목"
        specialTitle.textColor = .black
        specialTitle.borderStyle = .none
        specialTitle.font = .systemFont(ofSize: 15)
        specialTitle.layer.masksToBounds = true
        return specialTitle
    }()
    // specialTitle border 구현
    private lazy var border: CALayer = {
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: specialTitle.frame.size.height - width, width: specialTitle.frame.width, height: specialTitle.frame.size.height)
        border.borderWidth = width
        return border
    }()
    
    override func layoutSubviews() {
            super.layoutSubviews()
            specialTitle.layer.addSublayer(border)
        }
    
    //MARK: - 설명 입력
    private lazy var descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.text = "설명"
        descriptionLabel.textColor = .black
        descriptionLabel.font = UIFont.systemFont(ofSize: 20)
        return descriptionLabel
    }()
    // textView placeholder
    let textViewPlaceholder: UILabel = {
        let textViewPlaceholder = UILabel()
        textViewPlaceholder.text = "내용을 입력해주세요"
        textViewPlaceholder.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        textViewPlaceholder.textColor = .textFieldPlaceholder
        return textViewPlaceholder
    }()
    private lazy var descriptionTextView: UITextView = {
        let descriptionTextView = UITextView()
        descriptionTextView.textContainerInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        descriptionTextView.font = .systemFont(ofSize: 15)
        descriptionTextView.textColor = .secondaryLabel
        descriptionTextView.backgroundColor = UIColor(named: "textFieldSegmentBG")
        descriptionTextView.layer.cornerRadius = 5
        return descriptionTextView
    }()
    
    
    //MARK: - 설명 글자 수 카운트 및 제한 표시
    private lazy var countTextLabel: UILabel = {
        let countTextLabel = UILabel()
        countTextLabel.text = "0/1000"
        countTextLabel.font = .systemFont(ofSize: 10)
        countTextLabel.textColor = .lightGray
        return countTextLabel
    }()
    
    //MARK: - 등록 버튼
    private lazy var saveButton: UIButton = {
        let saveButton = UIButton(type: .system)
        saveButton.setTitle("등록하기", for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        saveButton.backgroundColor = UIColor(named: "addBtnGraphTabbarColor")
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 5
        saveButton.layer.shadowColor = UIColor.darkGray.cgColor
        saveButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        saveButton.layer.shadowOpacity = 0.5
        saveButton.layer.shadowColor = UIColor.darkGray.cgColor
        saveButton.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
        return saveButton
    }()
    
    // MARK: - 레이아웃
    private func setupUI() {
        self.backgroundColor = .white
        
        self.addSubview(dateLabel)
        self.addSubview(datePicker)
        self.addSubview(specialTitle)
        self.addSubview(descriptionLabel)
        self.addSubview(descriptionTextView)
        self.addSubview(textViewPlaceholder)
        self.addSubview(countTextLabel)
        self.addSubview(saveButton)
        
        //MARK: -- UI AutoLayout
        
        dateLabel.snp.makeConstraints{ (make) in
            make.leading.equalTo(25)
            make.top.equalTo(imagePickerCollectionView.snp.bottomMargin).offset(30)
            
        }
        
        datePicker.snp.makeConstraints{(make) in
            make.width.equalTo(100)
            make.leading.equalTo(20)
            make.top.equalTo(dateLabel.snp.bottomMargin).offset(20)
        }
        
        specialTitle.snp.makeConstraints{(make) in
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.width.equalTo(self).offset(-50)
            make.top.equalTo(datePicker.snp.bottom).offset(10)
        }
        
        descriptionLabel.snp.makeConstraints{(make) in
            make.leading.equalTo(25)
            make.top.equalTo(specialTitle.snp.bottomMargin).offset(30)
        }
        
        descriptionTextView.snp.makeConstraints{(make) in
            make.centerX.equalTo(self)
            make.height.equalTo(250)
            make.width.equalTo(self).offset(-40)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
        }
        
        textViewPlaceholder.snp.makeConstraints { make in
            make.top.equalTo(descriptionTextView.snp.top).offset(8)
            make.leading.equalTo(descriptionTextView.snp.leading).offset(14)
        }
        
        countTextLabel.snp.makeConstraints{(make) in
            make.trailing.equalTo(descriptionTextView.snp.trailingMargin)
            make.bottom.equalTo(descriptionTextView.snp.bottomMargin)
        }
        
        saveButton.snp.makeConstraints{(make) in
            make.centerX.equalTo(self)
            make.height.equalTo(50)
            make.width.equalTo(self).offset(-40)
            make.top.equalTo(descriptionTextView.snp.bottom).offset(30)
        }
    }
    //MARK: - 이미지피커 콜렉션뷰 setup
    private func setupImagePickerCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: 90, height: 90)
        
        imagePickerCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        imagePickerCollectionView.register(SpecialPHPickerCollectionViewCell.self, forCellWithReuseIdentifier: "PHPickerCell")
        imagePickerCollectionView.showsHorizontalScrollIndicator = false
        
        self.addSubview(imagePickerCollectionView)
        
        imagePickerCollectionView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.equalTo(self.snp.leading).offset(24)
            make.trailing.equalTo(self.snp.trailing)
            make.height.equalTo(90)
        }
    }

    //MARK: - saveButton 액션 함수
    @objc
    private func saveButtonAction() {
        delegate?.didTapPostButton(imageData: imageData, title: specialTitle.text ?? "nil", content: descriptionTextView.text ?? "nil")
    }
    //MARK: - Delegate
    func configureSpecialEditView(delegate: UICollectionViewDelegate, datasource: UICollectionViewDataSource, textViewDelegate: UITextViewDelegate) {
        imagePickerCollectionView.delegate = delegate
        imagePickerCollectionView.dataSource = datasource
        descriptionTextView.delegate = textViewDelegate
    }
    //MARK: - PHPicker 함수
    func createPHPickerVC() -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 5
        config.filter = .images
        
        return PHPickerViewController(configuration: config)
        
    }

}

// MARK: - 키보드 관련
extension SpecialEditView: KeyboardNotificationDelegate {
    func keyboardWillShow(keyboardSize: CGRect) {
        print("keyboard Show")
        
        if isTextViewFirstResponder() {
            self.imagePickerCollectionView.snp.remakeConstraints { make in
                make.top.equalTo(self.snp.top)
                make.leading.equalTo(self.snp.leading).offset(24)
                make.trailing.equalTo(self.snp.trailing)
                make.height.equalTo(90)
            }
            
            // 레이아웃 변화를 애니메이션으로 적용
            self.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide(keyboardSize: CGRect) {
        print("keyboardW Hide")
        
        if isTextViewFirstResponder() {
            self.imagePickerCollectionView.snp.remakeConstraints { make in
                make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(10)
                make.leading.equalTo(self.snp.leading).offset(24)
                make.trailing.equalTo(self.snp.trailing)
                make.height.equalTo(90)
            }
            
            // 레이아웃 변화를 애니메이션으로 적용
            self.layoutIfNeeded()
        }
    }
    
    private func isTextViewFirstResponder() -> Bool {
        // 모든 서브뷰를 검색해서 UITextView가 첫 번째 응답자인지 확인함
        for subview in self.subviews {
            if let textView = subview as? UITextView, textView.isFirstResponder {
                return true
            }
        }
        return false
    }
}
