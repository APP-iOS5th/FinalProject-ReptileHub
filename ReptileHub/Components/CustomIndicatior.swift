//
//  CustomIndicatior.swift
//  ReptileHub
//
//  Created by 임재현 on 9/10/24.
//

import UIKit
import SnapKit

//class CustomActivityIndicator: UIView {
//    private let activityIndicator = UIActivityIndicatorView(style: .medium)
//    private let messageLabel = UILabel()
//    private let messageImage = UIImageView(image: UIImage(named:"choba"))
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupView()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupView()
//    }
//
//    private func setupView() {
//        self.backgroundColor = UIColor(white: 0, alpha: 0.7) // 반투명 배경색 설정
//        self.layer.cornerRadius = 10
//
//        
//        
//        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
//        messageLabel.translatesAutoresizingMaskIntoConstraints = false
//
//    
//        messageLabel.text = "게시글을 등록 중입니다...\n잠시만 기다려 주세요."
//        messageLabel.textAlignment = .center
//        messageLabel.numberOfLines = 0
//        messageLabel.textColor = .white
//
//        self.addSubview(activityIndicator)
//        self.addSubview(messageLabel)
//        self.addSubview(messageImage)
//        
//        
//        activityIndicator.snp.makeConstraints {
//            $0.top.equalToSuperview().offset(20)
//            $0.centerX.equalToSuperview()
//            $0.width.height.equalTo(240)
//        }
//        
//        messageImage.snp.makeConstraints {
//            $0.top.equalTo(messageLabel).offset(10)
//            $0.width.height.equalTo(100)
//            $0.centerX.equalToSuperview()
//        }
//
//        NSLayoutConstraint.activate([
//            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
//            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -20),
//
//            messageLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 10),
//            messageLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
//            messageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20)
//        ])
//    }
//
//    func startAnimating() {
//        activityIndicator.startAnimating()
//       print("zz1122312312312")
//        self.isHidden = false
//    }
//
//    func stopAnimating() {
//        activityIndicator.stopAnimating()
//        print("RMxskadsmflkasmd;flkasdfm")
//        self.isHidden = true
//    }
//}

//class CustomActivityIndicator: UIView {
//    private let activityIndicator = UIActivityIndicatorView(style: .large)
//    private let messageLabel = UILabel()
//    private let progressBar = UIProgressView(progressViewStyle: .default)
//    private var progress: Float = 0.0
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupView()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupView()
//    }
//
//    private func setupView() {
//        // 배경색 설정
//        self.backgroundColor = UIColor(white: 0, alpha: 0.8)
//        self.layer.cornerRadius = 10
//        self.clipsToBounds = true
//
//        // Activity Indicator 설정
//        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
//        self.addSubview(activityIndicator)
//
//        // Message Label 설정
//        messageLabel.text = "게시글을 등록 중입니다...\n잠시만 기다려 주세요."
//        messageLabel.textAlignment = .center
//        messageLabel.numberOfLines = 0
//        messageLabel.textColor = .white
//        messageLabel.translatesAutoresizingMaskIntoConstraints = false
//        self.addSubview(messageLabel)
//
//        // Progress Bar 설정
//        progressBar.translatesAutoresizingMaskIntoConstraints = false
//        progressBar.progressTintColor = UIColor.systemBlue // 로딩바 색상
//        progressBar.trackTintColor = UIColor.lightGray
//        self.addSubview(progressBar)
//
//        // SnapKit을 사용한 레이아웃
//        activityIndicator.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.centerY.equalToSuperview().offset(-40)
//        }
//
//        messageLabel.snp.makeConstraints { make in
//            make.top.equalTo(activityIndicator.snp.bottom).offset(10)
//            make.leading.equalToSuperview().offset(20)
//            make.trailing.equalToSuperview().offset(-20)
//        }
//
//        progressBar.snp.makeConstraints { make in
//            make.top.equalTo(messageLabel.snp.bottom).offset(20)
//            make.leading.equalToSuperview().offset(20)
//            make.trailing.equalToSuperview().offset(-20)
//            make.height.equalTo(4)
//        }
//    }
//
//    func startAnimating() {
//        self.isHidden = false
//        activityIndicator.startAnimating()
//        startProgressBarAnimation()
//    }
//
//    func stopAnimating() {
//        self.isHidden = true
//        activityIndicator.stopAnimating()
//        progressBar.setProgress(0.0, animated: false)
//    }
//
//    private func startProgressBarAnimation() {
//        progress = 0.0
//        progressBar.setProgress(progress, animated: true)
//
//        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
//            self.progress += 0.01
//            self.progressBar.setProgress(self.progress, animated: true)
//
//            if self.progress >= 1.0 {
//                timer.invalidate()
//            }
//        }
//    }
//}

//class CustomActivityIndicator: UIView {
//    private let activityIndicator = UIActivityIndicatorView(style: .large)
//    private let messageLabel = UILabel()
//    private let progressBar = UIProgressView(progressViewStyle: .default)
//    private var progress: Float = 0.0
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupView()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupView()
//    }
//
//    private func setupView() {
//        // 배경색 설정
//        self.backgroundColor = UIColor(white: 0, alpha: 0.8)
//        self.layer.cornerRadius = 10
//        self.clipsToBounds = true
//
//        // Activity Indicator 설정
//        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
//        self.addSubview(activityIndicator)
//
//        // Message Label 설정
//        messageLabel.text = "게시글을 등록 중입니다...\n잠시만 기다려 주세요."
//        messageLabel.textAlignment = .center
//        messageLabel.numberOfLines = 0
//        messageLabel.textColor = .white
//        messageLabel.translatesAutoresizingMaskIntoConstraints = false
//        self.addSubview(messageLabel)
//
//        // Progress Bar 설정
//        progressBar.translatesAutoresizingMaskIntoConstraints = false
//        progressBar.progressTintColor = UIColor.systemBlue // 로딩바 색상
//        progressBar.trackTintColor = UIColor.lightGray
//        self.addSubview(progressBar)
//
//        // SnapKit을 사용한 레이아웃
//        activityIndicator.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.centerY.equalToSuperview().offset(-40)
//        }
//
//        messageLabel.snp.makeConstraints { make in
//            make.top.equalTo(activityIndicator.snp.bottom).offset(10)
//            make.leading.equalToSuperview().offset(20)
//            make.trailing.equalToSuperview().offset(-20)
//        }
//
//        progressBar.snp.makeConstraints { make in
//            make.top.equalTo(messageLabel.snp.bottom).offset(20)
//            make.leading.equalToSuperview().offset(20)
//            make.trailing.equalToSuperview().offset(-20)
//            make.height.equalTo(4)
//        }
//    }
//
//    func startAnimating() {
//        self.isHidden = false
//        activityIndicator.startAnimating()
//        startProgressBarAnimation()
//    }
//
//    func stopAnimating() {
//        self.isHidden = true
//        activityIndicator.stopAnimating()
//        progressBar.setProgress(0.0, animated: false)
//    }
//
//    private func startProgressBarAnimation() {
//        progress = 0.0
//        progressBar.setProgress(progress, animated: true)
//
//        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
//            self.progress += 0.01
//            self.progressBar.setProgress(self.progress, animated: true)
//
//            if self.progress >= 1.0 {
//                timer.invalidate()
//                
//                // ProgressBar가 끝까지 찼을 때 메시지 변경
//                DispatchQueue.main.async {
//                    self.messageLabel.text = "거의 다 완료되었습니다. 조금만 더 기다려주세요."
//                }
//            }
//        }
//    }
//}

//class CustomActivityIndicator: UIView {
//    private let activityIndicator = UIActivityIndicatorView(style: .large)
//    private let messageLabel = UILabel()
//    private let progressBar = UIProgressView(progressViewStyle: .default)
//    private var progress: Float = 0.0
//    
//    // 초기 메시지를 설정할 수 있는 이니셜라이저 추가
//    init(initialMessage: String = "게시글을 등록 중입니다...\n잠시만 기다려 주세요.") {
//        super.init(frame: .zero)
//        setupView()
//        messageLabel.text = initialMessage
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupView()
//    }
//    
//    private func setupView() {
//        self.backgroundColor = UIColor(white: 0, alpha: 0.8)
//        self.layer.cornerRadius = 10
//        self.clipsToBounds = true
//        
//        self.addSubview(activityIndicator)
//        self.addSubview(messageLabel)
//        self.addSubview(progressBar)
//        
//        messageLabel.textAlignment = .center
//        messageLabel.numberOfLines = 0
//        messageLabel.textColor = .white
//        
//        // Progress Bar 설정
//        progressBar.progressTintColor = UIColor.systemBlue
//        progressBar.trackTintColor = UIColor.lightGray
//        
//        
//        activityIndicator.snp.makeConstraints {
//            $0.centerX.equalToSuperview()
//            $0.centerY.equalToSuperview().offset(-40)
//        }
//        
//        messageLabel.snp.makeConstraints {
//            $0.top.equalTo(activityIndicator.snp.bottom).offset(10)
//            $0.leading.equalToSuperview().offset(20)
//            $0.trailing.equalToSuperview().offset(-20)
//        }
//        
//        progressBar.snp.makeConstraints {
//            $0.top.equalTo(messageLabel.snp.bottom).offset(20)
//            $0.leading.equalToSuperview().offset(20)
//            $0.trailing.equalToSuperview().offset(-20)
//            $0.height.equalTo(4)
//        }
//    }
//    
//    func startAnimating() {
//        self.isHidden = false
//        activityIndicator.startAnimating()
//        print("시작한다 하하하하핳하")
//        startProgressBarAnimation()
//    }
//    
//    func stopAnimating() {
//        self.isHidden = true
//        activityIndicator.stopAnimating()
//        print("끝났다 하하하하하하 하하하하핳하")
//        progressBar.setProgress(0.0, animated: false)
//    }
//    
//    private func startProgressBarAnimation() {
//        progress = 0.0
//        progressBar.setProgress(progress, animated: true)
//        
//        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
//            self.progress += 0.01
//            self.progressBar.setProgress(self.progress, animated: true)
//            
//            if self.progress >= 1.0 {
//                timer.invalidate()
//                
//                // ProgressBar가 끝까지 찼을 때 메시지 변경
//                DispatchQueue.main.async {
//                    self.messageLabel.text = "마무리 작업중입니다 \n 조금만 더 기다려주세요"
//                }
//            }
//        }
//    }
//    
//    // 메시지를 업데이트하는 함수
//      func updateMessage(_ message: String) {
//          messageLabel.text = message
//      }
//    
//    
//}


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
