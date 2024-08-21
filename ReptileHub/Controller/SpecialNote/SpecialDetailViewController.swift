//
//  SpecialDetailViewController.swift
//  ReptileHub
//
//  Created by 황민경 on 8/21/24.
//

import UIKit
import SnapKit

class SpecialDetailViewController: UIViewController {
    
//    private let scrollView: UIScrollView = UIScrollView()
//    private let stackView: UIStackView = UIStackView()
    
    private var specialImages: [UIImageView] = [
        UIImageView(image: UIImage(named: "Snowball")),
        UIImageView(image: UIImage(named: "Snowball")),
        UIImageView(image: UIImage(named: "Snowball")),
        ]
    private var imageViews: [UIView] = []
    private let imageStackView: UIStackView = UIStackView()
    private let imageScrollView: UIScrollView = UIScrollView()
    
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
    private var specialTitle: UILabel = {
        let specailTitle = UILabel()
        specailTitle.text = "일지 제목"
        specailTitle.font = .systemFont(ofSize: 20, weight: .bold)
        specailTitle.textColor = .black
        return specailTitle
    }()
    private var specialLizardName: UILabel = {
        let specialLizardName = UILabel()
        specialLizardName.text = "반려도마뱀 이름"
        specialLizardName.font = .systemFont(ofSize: 10, weight: .semibold)
        specialLizardName.textColor = .darkGray
        return specialLizardName
    }()
    private var dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.text = "2024.08.14"
        dateLabel.font = .systemFont(ofSize: 10, weight: .semibold)
        dateLabel.textColor = UIColor(named: "Light_Gray")
        return dateLabel
    }()
    private var specialLine: UIView = {
        let specialLine = UIView()
        specialLine.backgroundColor = UIColor(named: "Light_Gray")
        return specialLine
    }()
    private var specialText: UILabel = {
        let specialText = UILabel()
        specialText.text = "동해물과 백두산이 마르고 닳도록 하느님이 보우하사 우리나라 만세. 무궁화 삼천리 화려강산 대한사람 대한으로 길이 보전하세"
        specialText.numberOfLines = .bitWidth
        specialText.font = .systemFont(ofSize: 10)
        specialText.textColor = .black
        return specialText
    }()
    private var ellipsis: UIImageView = {
        let ellipsis = UIImageView()
        ellipsis.image = UIImage(systemName: "ellipsis")
        ellipsis.tintColor = .darkGray
        ellipsis.contentMode = .center
        ellipsis.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        return ellipsis
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailsetupUI()
        setupImageScrollView()
        setupImagePageCountLabel()
        // Do any additional setup after loading the view.
    }
    
    private func detailsetupUI() {
        view.backgroundColor = .white
        navigationItem.title = "특이사항"
//        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(editButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: ellipsis)
        
//        view.addSubview(specialImages)
//        view.addSubview(imageRectangle)
//        view.addSubview(imageCountNumber)
//        view.addSubview(specialTitle)
//        view.addSubview(specialLizardName)
//        view.addSubview(dateLabel)
//        view.addSubview(specialLine)
//        view.addSubview(specialText)
        
//        specialImages.snp.makeConstraints{(make) in
//            make.width.equalTo(100)
//            make.height.equalTo(100)
//            make.centerX.equalTo(self.view)
//            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
//
//        }
        
        pageCountView.snp.makeConstraints{(make) in
            
        }
        imagePageCount.snp.makeConstraints{(make) in
            
        }
        specialTitle.snp.makeConstraints{(make) in
            
        }
        specialLizardName.snp.makeConstraints{(make) in
            
        }
        dateLabel.snp.makeConstraints{(make) in
            
        }
        specialLine.snp.makeConstraints{(make) in
            
        }
        specialText.snp.makeConstraints{(make) in
            
        }
    }
    @objc private func editButton() {

    }
    
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension SpecialDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        self.imagePageCount.text = "\(pageIndex + 1)/(self.contentImages.count)"
       }
}
