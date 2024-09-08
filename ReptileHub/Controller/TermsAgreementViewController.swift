//
//  TermsAgreementViewController.swift
//  ReptileHub
//
//  Created by 임재현 on 8/8/24.
//

import UIKit
import GoogleSignIn

class TermsAgreementViewController: UIViewController {
    var user: AuthUser
    var onAgreementAccepted: (()->Void)?
    var onAgreementDeclined: (()->Void)?
    
    private let titleLabel = UILabel()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let textLabel = UILabel()
    private let agreeButton = UIButton(type: .custom)
    private let declineButton = UIButton(type: .custom)
    private let buttonStackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        print("termsAgreement View did Load")
    }
    
    init(user:AuthUser) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    func configUI() {
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        
        titleLabel.text = "개인정보 수집 동의"
        titleLabel.font = UIFont.systemFont(ofSize: 25, weight: .light)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(15)
            make.centerX.equalTo(self.view)
        }
        
        view.addSubview(scrollView)
        
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.addSubview(textLabel)
        scrollView.layer.cornerRadius = 10
        scrollView.backgroundColor = .textFieldPlaceholder.withAlphaComponent(0.4)
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(25)
            make.width.equalTo(self.view.bounds.width * 0.7)
            make.height.equalTo(self.view.bounds.height * 0.7)
            make.leading.equalTo(self.view.snp.leading).offset(24)
            make.trailing.equalTo(self.view.snp.trailing).offset(-24)
        }
        
        scrollView.addSubview(contentView)
    
        
        contentView.snp.makeConstraints { make in
            make.width.equalTo(scrollView)
            make.top.bottom.leading.trailing.equalTo(scrollView)
        }
        
        contentView.addSubview(textLabel)
        
        textLabel.text = readTextFile()
        textLabel.numberOfLines = 0
        
        textLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(contentView).offset(8)
            make.bottom.trailing.equalTo(contentView).offset(-8)
        }
        
        view.addSubview(buttonStackView)
        
        buttonStackView.axis = .horizontal
        buttonStackView.alignment = .fill
        buttonStackView.distribution = .equalCentering
        
        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom).offset(25)
            make.centerX.equalTo(self.view)
            make.width.equalTo(200)
            make.height.equalTo(40)
//            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-30)
        }
        
        buttonStackView.addArrangedSubview(agreeButton)
        buttonStackView.addArrangedSubview(declineButton)
        
        agreeButton.backgroundColor = .addBtnGraphTabbar
        agreeButton.setTitleColor(.white, for: .normal)
        agreeButton.layer.cornerRadius = 5
        
        agreeButton.snp.makeConstraints { make in
            make.width.equalTo(50)
        }
        
        declineButton.backgroundColor = .lightGray
        declineButton.setTitleColor(.white, for: .normal)
        declineButton.layer.cornerRadius = 5
        
        declineButton.snp.makeConstraints { make in
            make.width.equalTo(100)
        }
        
        agreeButton.addTarget(self, action: #selector(agreeButtonTapped), for: .touchUpInside)
        declineButton.addTarget(self, action: #selector(declineButtonTapped), for: .touchUpInside)
        agreeButton.setTitle("동의", for: .normal)
        declineButton.setTitle("동의 안함", for: .normal)
        
    }
        
    @objc private func agreeButtonTapped() {
        onAgreementAccepted?()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func declineButtonTapped() {
        onAgreementDeclined?()
        self.dismiss(animated: true, completion: nil)

    }
}
