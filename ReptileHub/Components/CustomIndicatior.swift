//
//  CustomIndicatior.swift
//  ReptileHub
//
//  Created by 임재현 on 9/10/24.
//

import UIKit
import SnapKit

class CustomActivityIndicator: UIView {
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let messageLabel = UILabel()
    private let progressBar = UIProgressView(progressViewStyle: .default)
    private var progress: Float = 0.0

    init(initialMessage: String = "게시글을 등록 중입니다...\n잠시만 기다려 주세요.") {
        super.init(frame: .zero)
        setupView()
        messageLabel.text = initialMessage
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        self.backgroundColor = UIColor(white: 0, alpha: 0.8)
        self.layer.cornerRadius = 10
        self.clipsToBounds = true

        self.addSubview(activityIndicator)
        self.addSubview(messageLabel)
        self.addSubview(progressBar)

        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.textColor = .white

        progressBar.progressTintColor = UIColor.systemBlue
        progressBar.trackTintColor = UIColor.lightGray

        activityIndicator.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-40)
        }

        messageLabel.snp.makeConstraints {
            $0.top.equalTo(activityIndicator.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        progressBar.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(4)
        }
    }

    func startAnimating(withMessage message: String? = nil) {
        if let message = message {
            messageLabel.text = message
        }
        self.isHidden = false
        activityIndicator.startAnimating()
        startProgressBarAnimation()
    }

    func stopAnimating() {
        self.isHidden = true
        activityIndicator.stopAnimating()
        progressBar.setProgress(0.0, animated: false)
    }

    private func startProgressBarAnimation() {
        progress = 0.0
        progressBar.setProgress(progress, animated: true)

        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
            self.progress += 0.01
            self.progressBar.setProgress(self.progress, animated: true)

            if self.progress >= 1.0 {
                timer.invalidate()
                DispatchQueue.main.async {
                    self.updateMessage("마무리 작업중입니다 \n 조금만 더 기다려주세요")
                }
            }
        }
    }

    func updateMessage(_ message: String) {
        messageLabel.text = message
    }
}
