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
    var authorizationCode: String?
    var onAgreementAccepted: (() -> Void)?
    var onAgreementDeclined: (() -> Void)?

    private let agreementView = TermsAgreementView() // AgreementView 추가

    init(user: AuthUser) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(agreeButton)
        view.addSubview(declineButton)
        
        agreeButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-20)
        }
      
        declineButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
            
            agreeButton.addTarget(self, action: #selector(agreeButtonTapped), for: .touchUpInside)
            declineButton.addTarget(self, action: #selector(declineButtonTapped), for: .touchUpInside)
            agreeButton.setTitleColor(.black, for: .normal)
            declineButton.setTitleColor(.black, for: .normal)
            agreeButton.setTitle("Agree", for: .normal) 
            declineButton.setTitle("Decline", for: .normal)
        }
        
        setupAgreementView()
        setupActions() // 액션 설정
    }

    private func setupAgreementView() {
        view.addSubview(agreementView)
        agreementView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupActions() {
        // AgreementView의 버튼 액션 설정
        agreementView.agreeButton.addTarget(self, action: #selector(agreeButtonTapped), for: .touchUpInside)
        agreementView.disagreeButton.addTarget(self, action: #selector(disagreeButtonTapped), for: .touchUpInside)
        
        // 추가적으로 이미지 뷰에 대한 제스처 액션 설정
        let agreeTapGesture = UITapGestureRecognizer(target: self, action: #selector(agreeButtonTapped))
        agreementView.agreeCheckImageView.addGestureRecognizer(agreeTapGesture)

        let disagreeTapGesture = UITapGestureRecognizer(target: self, action: #selector(disagreeButtonTapped))
        agreementView.disagreeCheckImageView.addGestureRecognizer(disagreeTapGesture)
    }

    @objc private func agreeButtonTapped() {
        agreementView.updateSelection(isAgreeSelected: true)
        onAgreementAccepted?()
        self.dismiss(animated: true, completion: nil)
    }

    @objc private func disagreeButtonTapped() {
        agreementView.updateSelection(isAgreeSelected: false)
        onAgreementDeclined?()
        self.dismiss(animated: true, completion: nil)
    }
}

