//
//  GrowthDiaryListCollectionViewCell.swift
//  ReptileHub
//
//  Created by 이상민 on 8/13/24.
//

import UIKit
import SnapKit

class GrowthDiaryListCollectionViewCell: UICollectionViewCell {
    static let identifier = "GrowthDiaryListCell"
    
    private lazy var GrowthDiaryItemImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var GrowthDiaryItemTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.setContentHuggingPriority(.required, for: .vertical)
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    private lazy var GrowthDiaryItemDate: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
    
    private func setUp(){
        contentView.addSubview(GrowthDiaryItemImage)
        contentView.addSubview(GrowthDiaryItemTitle)
        contentView.addSubview(GrowthDiaryItemDate)
        
        GrowthDiaryItemImage.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(contentView)
            make.width.equalTo(contentView.bounds.width)
            make.height.equalTo(GrowthDiaryItemImage.snp.width).multipliedBy(0.74)
        }
        
        GrowthDiaryItemTitle.snp.makeConstraints { make in
            make.top.equalTo(GrowthDiaryItemImage.snp.bottom).offset(10)
            make.leading.trailing.equalTo(contentView)
        }
        
        GrowthDiaryItemDate.snp.makeConstraints { make in
            make.leading.trailing.equalTo(contentView)
            make.top.equalTo(GrowthDiaryItemTitle.snp.bottom).offset(3)
            make.bottom.equalToSuperview()
        }
    }
    
    func configure(imageName: String, title: String, timestamp: Date){
        let formatter = DateFormatter()
        formatter.dateFormat = "YY. MM. dd 생성"
        formatter.locale = Locale(identifier: "ko_KR")
        
        GrowthDiaryItemImage.image = UIImage(named: imageName)
        GrowthDiaryItemTitle.text = title
        GrowthDiaryItemDate.text = "\(formatter.string(from: timestamp))"
    }
    
    func calculateHeight(width: CGFloat) -> CGFloat {
        // 데이터를 설정
        configure(imageName: "tempImage", title: "엘리자베스 몰리 2세의 성장일지", timestamp: Date())
        
        // 셀의 크기를 측정할 준비를 합니다.
        self.frame = CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude)
        self.layoutIfNeeded()
        
        // 시스템 레이아웃을 통해 셀의 적절한 크기를 계산합니다.
        let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        // Auto Layout 기준으로 너비/높이를 설정
        let fittingSize = self.systemLayoutSizeFitting(targetSize,
                                                       withHorizontalFittingPriority: .required,
                                                       verticalFittingPriority: .fittingSizeLevel)
        
        // 최종적으로 계산된 높이 반환
        return fittingSize.height
    }
}
