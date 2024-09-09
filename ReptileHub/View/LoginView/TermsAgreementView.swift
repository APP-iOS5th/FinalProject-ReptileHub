//
//  TermsAgreementView.swift
//  ReptileHub
//
//  Created by 임재현 on 9/8/24.
//

import UIKit
import SnapKit

class TermsAgreementView: UIView {
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "LogoImage") // 로고 이미지 설정
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "개인정보 수집 동의"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()

     let agreementTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.backgroundColor = UIColor.lightGray
        textView.layer.cornerRadius = 8
        textView.isScrollEnabled = true
        textView.text = ""
        return textView
    }()

    // 동의 버튼 옆의 체크 이미지
     let agreeCheckImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "circle")
        imageView.tintColor = .black
        return imageView
    }()

     let agreeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("동의", for: .normal)
//         button.showsTouchWhenHighlighted = false
//         button.adjustsImageWhenHighlighted = false
        return button
    }()

    // 동의 안함 버튼 옆의 체크 이미지
     let disagreeCheckImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "circle") 
        imageView.tintColor = .black
        return imageView
    }()

     let disagreeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("동의 안함", for: .normal)
        return button
    }()

    // 스택 뷰로 버튼과 체크 이미지를 정렬
     lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [agreeCheckImageView, agreeButton, UIView(), disagreeCheckImageView, disagreeButton])
        stackView.axis = .horizontal
        stackView.spacing = 10 // 기본 spacing
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupActions()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupActions()
    }
    
    private func readTextFile() -> String {
            var text = ""
            
            guard let path = Bundle.main.path(forResource: "PersonalInfo.txt", ofType: nil) else { return "" }
            do {
                text = try String(contentsOfFile: path, encoding: .utf8)
                return text
            } catch {
                return "Error : 개인정보수집동의.txt file read failed - \(error.localizedDescription)"
            }
        }

    private func setupView() {
        backgroundColor = .white

        // 뷰에 UI 요소들 추가
        addSubview(logoImageView)
        addSubview(titleLabel)
        addSubview(agreementTextView)
        addSubview(buttonStackView)

        agreementTextView.text = readTextFile()
        // 오토레이아웃 설정
        setupConstraints()
    }

    private func setupConstraints() {
        logoImageView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(24)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(144)
            $0.height.equalTo(77)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }

        agreementTextView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(400)
        }

        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(agreementTextView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
    }

    private func setupActions() {
        agreeButton.addTarget(self, action: #selector(agreeButtonTapped), for: .touchUpInside)
        disagreeButton.addTarget(self, action: #selector(disagreeButtonTapped), for: .touchUpInside)

        let agreeTapGesture = UITapGestureRecognizer(target: self, action: #selector(agreeButtonTapped))
        agreeCheckImageView.addGestureRecognizer(agreeTapGesture)
        agreeCheckImageView.isUserInteractionEnabled = true

        let disagreeTapGesture = UITapGestureRecognizer(target: self, action: #selector(disagreeButtonTapped))
        disagreeCheckImageView.addGestureRecognizer(disagreeTapGesture)
        disagreeCheckImageView.isUserInteractionEnabled = true
    }

    @objc private func agreeButtonTapped() {
        updateSelection(isAgreeSelected: true)
    }

    @objc private func disagreeButtonTapped() {
        updateSelection(isAgreeSelected: false)
    }

     func updateSelection(isAgreeSelected: Bool) {
        let agreeImage = isAgreeSelected ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle")
        let disagreeImage = isAgreeSelected ? UIImage(systemName: "circle") : UIImage(systemName: "checkmark.circle.fill")
        
        agreeCheckImageView.image = agreeImage
        disagreeCheckImageView.image = disagreeImage
    }
}
