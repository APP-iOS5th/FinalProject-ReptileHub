//
//  SpecialEditView.swift
//  ReptileHub
//
//  Created by 황민경 on 8/26/24.
//

import UIKit
import SnapKit

class SpecialEditView: UIView {
    
    
    override init(frame: CGRect) {
        super .init(frame: .zero)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: 갤러리 선택 버튼 - 버튼 클릭 시 갤러리 표시
    private lazy var imageButton: UIButton = {
        let imageButton = UIButton()
        imageButton.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        imageButton.tintColor = UIColor(named: "imagePickerPlaceholderColor")
        imageButton.backgroundColor = UIColor(named: "imagePickerColor")
        imageButton.layer.cornerRadius = 5
//        imageButton.layer.shadowOffset = CGSize(width: 1, height: 1)
//        imageButton.layer.shadowOpacity = 0.5
//        imageButton.layer.shadowColor = UIColor.darkGray.cgColor
        return imageButton
    }()
    
    //MARK: 날짜 (datePicker로 수정)
    private lazy var dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.text = "날짜"
        dateLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        dateLabel.textColor = .lightGray
        return dateLabel
    }()
    
    private lazy var dateButton: UIButton = {
        let dateButton = UIButton()
        dateButton.setTitle("yyyy.mm.dd", for: .normal)
        dateButton.setTitleColor(UIColor(named: "textFieldTitleColor"), for: .normal)
        dateButton.layer.cornerRadius = 5
        dateButton.backgroundColor = UIColor(named: "datePickerBG")
//        dateButton.layer.shadowOffset = CGSize(width: 1, height: 1)
//        dateButton.layer.shadowOpacity = 0.5
//        dateButton.layer.shadowColor = UIColor.darkGray.cgColor
        return dateButton
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
    
    
    // MARK: Selectors
    @objc
    private func handleDatePicker(_ sender: UIDatePicker) {
        print(sender.date)
    }
    
    //MARK: 제목 입력
    private lazy var specialTitle: UITextField = {
        let specialTitle = UITextField()
        specialTitle.placeholder = "제목"
        specialTitle.textColor = .black
        specialTitle.borderStyle = .none
        specialTitle.font = .systemFont(ofSize: 15)
        specialTitle.layer.masksToBounds = true
        return specialTitle
    }()
    
    private lazy var border: CALayer = {
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: specialTitle.frame.size.height - width, width: specialTitle.frame.width, height: specialTitle.frame.size.height)
        border.borderWidth = width
        return border
    }()
    
    // specialTitle border 구현
    override func layoutSubviews() {
            super.layoutSubviews()
            specialTitle.layer.addSublayer(border)
        }
    
    //MARK: 설명 입력
    private lazy var descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.text = "설명"
        descriptionLabel.textColor = .black
        descriptionLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return descriptionLabel
    }()
    
    private lazy var descriptionTextView: UITextView = {
        let descriptionTextView = UITextView()
        descriptionTextView.textContainerInset = .init(top: 10, left: 10, bottom: 10, right: 10)
//        descriptionTextView.contentInset = .init(top: 40, left: 30, bottom: 20, right: 10)
//        descriptionTextView.backgroundColor = .brown
//        descriptionTextView.textInputView.backgroundColor = UIColor(named: "Dark_Gray")
        descriptionTextView.text = "입력해주세요..."
        descriptionTextView.font = .systemFont(ofSize: 15)
        descriptionTextView.textColor = .secondaryLabel
        descriptionTextView.backgroundColor = UIColor(named: "textFieldSegmentBG")
//        descriptionTextView.delegate = self
        
        descriptionTextView.layer.cornerRadius = 5
        return descriptionTextView
    }()
    
    
    //MARK: 설명 글자 수 카운트 및 제한 표시
    private lazy var countTextLabel: UILabel = {
        let countTextLabel = UILabel()
        countTextLabel.text = "0/1000"
        countTextLabel.font = .systemFont(ofSize: 10)
        countTextLabel.textColor = .lightGray
        return countTextLabel
    }()
    
    //MARK: 등록 버튼
    private lazy var saveButton: UIButton = {
        let saveButton = UIButton()
        saveButton.setTitle("등록하기", for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        saveButton.backgroundColor = UIColor(named: "addBtnGraphTabbarColor")
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 5
        saveButton.layer.shadowColor = UIColor.darkGray.cgColor
        saveButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        saveButton.layer.shadowOpacity = 0.5
        saveButton.layer.shadowColor = UIColor.darkGray.cgColor
        return saveButton
    }()
    
    private func setupUI() {
        self.backgroundColor = .white
//        navigationItem.title = "특이사항"
        
        self.addSubview(imageButton)
        self.addSubview(dateLabel)
//        view.addSubview(dateButton)
        self.addSubview(datePicker)
        self.addSubview(specialTitle)
        self.addSubview(descriptionLabel)
        self.addSubview(descriptionTextView)
        self.addSubview(countTextLabel)
        self.addSubview(saveButton)
        
        //MARK: -- UI AutoLayout
        
        imageButton.snp.makeConstraints{(make) in
            make.width.equalTo(100)
            make.height.equalTo(100)
            make.leading.equalTo(20)
            make.top.equalTo(self.safeAreaLayoutGuide.snp.topMargin).offset(15)
        }
        
        dateLabel.snp.makeConstraints{ (make) in
            make.leading.equalTo(25)
            make.top.equalTo(imageButton.snp.bottomMargin).offset(30)
            
        }
        
//        dateButton.snp.makeConstraints{(make) in
//            make.width.equalTo(130)
//            make.leading.equalTo(20)
//            make.top.equalTo(dateLabel.snp.bottomMargin).offset(20)
//        }
        
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

}
