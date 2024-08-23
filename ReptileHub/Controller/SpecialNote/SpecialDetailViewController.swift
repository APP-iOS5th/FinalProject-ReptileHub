//
//  SpecialDetailViewController.swift
//  ReptileHub
//
//  Created by 황민경 on 8/21/24.
//

import UIKit
import SnapKit

class SpecialDetailViewController: UIViewController {
    
    // 특이사항 상세 뷰 이미지
    private var specialImages: [UIImageView] = [
        UIImageView(image: UIImage(named: "Snowball")),
        UIImageView(image: UIImage(named: "Snowball")),
        UIImageView(image: UIImage(named: "Snowball")),
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupImageScrollView()
        setupImagePageCountLabel()
        detailsetupUI()
        // Do any additional setup after loading the view.
    }
    
    // Navigationbar & UIMenu
    private func setupNavigationBar() {
        navigationItem.title = "특이사항"
        
        var ellipsis: UIButton = {
            let ellipsis = UIButton()
            ellipsis.setImage(UIImage(systemName: "ellipsis"), for: .normal)
            ellipsis.tintColor = .darkGray
            ellipsis.contentMode = .center
            ellipsis.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
            return ellipsis
        }()
        var menuItems: [UIAction] {
            return [
                UIAction(title: "수정하기", image: UIImage(systemName: "pencil"),handler: { [weak self]_ in
                    self?.navigateToEditScreen() }),
                UIAction(title: "삭제하기", image: UIImage(systemName: "trash"),attributes: .destructive,handler: { _ in}),
                
            ]
        }
        var menu: UIMenu {
            return UIMenu(title: "", image: nil, identifier: nil, options: [], children: menuItems)
        }
        
        let customBarButtonItem = UIBarButtonItem(customView: ellipsis)
        navigationItem.rightBarButtonItem = customBarButtonItem
        ellipsis.showsMenuAsPrimaryAction = true
        ellipsis.menu = menu
    }
    
    // 뷰 레이아웃
    private func detailsetupUI() {
        view.backgroundColor = .white
        
//        view.addSubview(specialImages)
//        view.addSubview(imageRectangle)
//        view.addSubview(imageCountNumber)
        view.addSubview(specialTitle)
        view.addSubview(specialLizardName)
        view.addSubview(dateLabel)
        view.addSubview(specialLine)
        view.addSubview(specialText)
        
//        specialImages.snp.makeConstraints{(make) in
//            make.width.equalTo(100)
//            make.height.equalTo(100)
//            make.centerX.equalTo(self.view)
//            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
//
//        }
        
//        pageCountView.snp.makeConstraints{(make) in
//            
//        }
//        imagePageCount.snp.makeConstraints{(make) in
//            
//        }
        specialTitle.snp.makeConstraints{(make) in
            make.leading.equalTo(self.view).offset(20)
            make.top.equalTo(imageScrollView.snp.bottom).offset(20)
        }
        specialLizardName.snp.makeConstraints{(make) in
            make.leading.equalTo(self.view).offset(20)
            make.top.equalTo(specialTitle.snp.bottom).offset(10)
        }
        dateLabel.snp.makeConstraints{(make) in
            make.trailing.equalTo(self.view).offset(-20)
            make.centerY.equalTo(specialLizardName)
        }
        specialLine.snp.makeConstraints{(make) in
            make.height.equalTo(1)
            make.width.equalToSuperview().offset(-40)
            make.centerX.equalTo(self.view)
            make.top.equalTo(dateLabel.snp.bottom).offset(20)
        }
        specialText.snp.makeConstraints{(make) in
            make.centerX.equalTo(self.view)
            make.width.equalToSuperview().offset(-50)
            make.top.equalTo(specialLine.snp.bottom).offset(20)
        }
    }
    // 수정 화면으로 전환하는 함수
        private func navigateToEditScreen() {
            let editViewController = SpecialEditViewController()
            navigationController?.pushViewController(editViewController, animated: true)
        }
    // 이미지 스크롤 뷰 레이아웃
    private func setupImageScrollView() {
        imageStackView.axis = .horizontal
        imageStackView.distribution = .fill
        imageStackView.alignment = .center
        imageStackView.backgroundColor = .green
        
        for i in 0..<specialImages.count {
            let imageView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: imageScrollView.frame.width, height: imageScrollView.frame.height))
            
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
            imageView.snp.makeConstraints { (make) -> Void in
                make.height.equalTo(230)
                make.width.equalTo(self.view.frame.width)
            }
            imageStackView.addArrangedSubview(imageView)
        }
        
        imageScrollView.alwaysBounceHorizontal = true
        imageScrollView.addSubview(imageStackView)
        imageScrollView.isPagingEnabled = true
        imageScrollView.delegate = self
        
        self.view.addSubview(imageScrollView)
        
        imageScrollView.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(230)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            make.leading.equalTo(self.view.snp.leading)
            make.trailing.equalTo(self.view.snp.trailing)
        }
        
        imageStackView.snp.makeConstraints { (make) -> Void in
            make.top.leading.trailing.bottom.equalTo(imageScrollView)
        }
    }
    // 이미지 카운트 레이아웃
    private func setupImagePageCountLabel() {
        pageCountView.backgroundColor = .lightGray
        pageCountView.layer.cornerRadius = 12
        
        pageCountView.addSubview(imagePageCount)

        self.view.addSubview(pageCountView)

        
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

}
// 이미지 스크롤 카운트
extension SpecialDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.frame.width > 0 else {
            return
        }
        let pageIndex = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        self.imagePageCount.text = "\(pageIndex + 1)/ \(self.specialImages.count)"
    }
}
