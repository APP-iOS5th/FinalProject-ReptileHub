//
//  SpecialDetailView.swift
//  ReptileHub
//
//  Created by 황민경 on 8/26/24.
//

import UIKit
import SnapKit

class SpecialDetailView: UIView {

    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setupImageScrollView()
        setupImagePageCountLabel()
        detailsetupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 특이사항 상세 뷰 이미지
    private var specialImages: [UIImageView] = [
//        UIImageView(image: UIImage(named: "tempImage")),
//        UIImageView(image: UIImage(named: "tempImage")),
//        UIImageView(image: UIImage(named: "tempImage")),
        ]
    // 특이사항 상세 뷰 이미지 뷰
    private var imageViews: [UIView] = []
    private let imageStackView: UIStackView = UIStackView()
    private let imageScrollView: UIScrollView = UIScrollView()
    
    // 특이사항 상세 뷰 이미지 카운트 뷰
    private var pageCountView: UIView = {
        let imageRectangle = UIView()
        imageRectangle.layer.cornerRadius = 100
        imageRectangle.backgroundColor = UIColor(white: 0, alpha: 0.8)
        return imageRectangle
    }()
    private var imagePageCount: UILabel = {
        let imageCountNumber = UILabel()
//        imageCountNumber.text = "1/3"
        imageCountNumber.font = .systemFont(ofSize: 8)
        return imageCountNumber
    }()
    
    // 특이사항 상세 뷰 제목
    private var specialTitle: UILabel = {
        let specailTitle = UILabel()
        specailTitle.text = "일지 제목"
        specailTitle.font = .systemFont(ofSize: 22, weight: .bold)
        specailTitle.textColor = .black
        return specailTitle
    }()
    // 특이사항 상세 뷰 반려도마뱀 이름
    private var specialLizardName: UILabel = {
        let specialLizardName = UILabel()
        specialLizardName.text = "반려도마뱀 이름"
        specialLizardName.font = .systemFont(ofSize: 14, weight: .semibold)
        specialLizardName.textColor = .darkGray
        return specialLizardName
    }()
    // 특이사항 상세 뷰 날짜
    private var dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.text = "2024.08.14"
        dateLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        dateLabel.textColor = .lightGray
        return dateLabel
    }()
    // 특이사항 상세 뷰 라인
    private var specialLine: UIView = {
        let specialLine = UIView()
        specialLine.backgroundColor = .lightGray
        return specialLine
    }()
    // 특이사항 상세 뷰 내용
    private var specialText: UILabel = {
        let specialText = UILabel()
        specialText.text = "동해물과 백두산이 마르고 닳도록 하느님이 보우하사 우리나라 만세. 무궁화 삼천리 화려강산 대한사람 대한으로 길이 보전하세. 남산 위에 저 소나무 철갑을 두른 듯 바람 서리 불변함은 우리 기상일세. 무궁화 삼천리 화려강산 대한사람 대한으로 길이 보전하세."
        specialText.numberOfLines = 0
        specialText.font = .systemFont(ofSize: 12)
        specialText.textColor = .black
        return specialText
    }()
    
    
    
    //MARK: -  뷰 레이아웃
    private func detailsetupUI() {
        self.backgroundColor = .white
        
        self.addSubview(specialTitle)
        self.addSubview(specialLizardName)
        self.addSubview(dateLabel)
        self.addSubview(specialLine)
        self.addSubview(specialText)
        
        specialTitle.snp.makeConstraints{(make) in
            make.leading.equalTo(self).offset(20)
            make.top.equalTo(imageScrollView.snp.bottom).offset(20)
        }
        specialLizardName.snp.makeConstraints{(make) in
            make.leading.equalTo(self).offset(20)
            make.top.equalTo(specialTitle.snp.bottom).offset(10)
        }
        dateLabel.snp.makeConstraints{(make) in
            make.trailing.equalTo(self).offset(-20)
            make.centerY.equalTo(specialLizardName)
        }
        specialLine.snp.makeConstraints{(make) in
            make.height.equalTo(1)
            make.width.equalToSuperview().offset(-40)
            make.centerX.equalTo(self)
            make.top.equalTo(dateLabel.snp.bottom).offset(20)
        }
        specialText.snp.makeConstraints{(make) in
            make.centerX.equalTo(self)
            make.width.equalToSuperview().offset(-40)
            make.top.equalTo(specialLine.snp.bottom).offset(20)
        }
    }
    
    //MARK: -  이미지 스크롤 뷰 레이아웃
    private func setupImageScrollView() {
        imageStackView.axis = .horizontal
        imageStackView.distribution = .fill
        imageStackView.alignment = .center
        imageStackView.backgroundColor = .green
        
        imageScrollView.alwaysBounceHorizontal = true
//        imageScrollView.addSubview(imageStackView)
        imageScrollView.isPagingEnabled = true
        imageScrollView.delegate = self
        
        self.addSubview(imageScrollView)
        
        imageScrollView.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(230)
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(12)
            make.leading.equalTo(self.snp.leading)
            make.trailing.equalTo(self.snp.trailing)
        }
        
        imageScrollView.addSubview(imageStackView)
        
        imageStackView.snp.makeConstraints { (make) -> Void in
            make.top.leading.trailing.bottom.equalTo(imageScrollView)
        }
        
        for i in 0..<specialImages.count {
            let imageView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 230))
            
            specialImages[i].contentMode = .scaleAspectFit
            
            imageView.addSubview(specialImages[i])
            
            specialImages[i].snp.makeConstraints { (make) -> Void in
                make.centerX.equalTo(imageView)
                make.height.equalTo(230)
            }
            
            imageViews.append(imageView)
        }
        
        for imageView in imageViews {
            imageView.backgroundColor = .gray
            imageStackView.addArrangedSubview(imageView)
            
            imageView.snp.makeConstraints { (make) -> Void in
                make.height.equalTo(230)
                make.width.equalTo(imageScrollView)
            }
        }
    }
    //MARK: - 이미지 카운트 레이아웃
    private func setupImagePageCountLabel() {
        pageCountView.backgroundColor = .lightGray
        pageCountView.layer.cornerRadius = 12
        
        pageCountView.addSubview(imagePageCount)

        self.addSubview(pageCountView)

        
        pageCountView.snp.makeConstraints { make in
            make.height.equalTo(27)
            make.width.equalTo(40)
            make.trailing.equalTo(imageScrollView.snp.trailing).offset(-10)
            make.bottom.equalTo(imageScrollView.snp.bottom).offset(-10)
        }
        
        imagePageCount.text = "1/\(specialImages.count)"
        imagePageCount.backgroundColor = .lightGray
        
        imagePageCount.snp.makeConstraints { make in
            make.centerX.equalTo(pageCountView)
            make.centerY.equalTo(pageCountView)
        }
    }
    func writeSpecialDetail(data: SpecialEntry) {
        print("안되면 울거야",specialImages)
        specialImages.append(contentsOf: data.image.map{ UIImageView(image: $0)})
        print("제발 되게 해주세요.",specialImages)
        specialTitle.text = data.specialTitle
        dateLabel.text = data.date.toString()
        specialText.text = data.specialText
//        print(data.image ?? UIImage(systemName: "person")!)
        setupImageScrollView()
        setupImagePageCountLabel()
    }
    
}
//MARK: - 이미지 스크롤 카운트
extension SpecialDetailView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.frame.width > 0 else {
            return
        }
        let pageIndex = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        self.imagePageCount.text = "\(pageIndex + 1)/ \(self.specialImages.count)"
    }
}
