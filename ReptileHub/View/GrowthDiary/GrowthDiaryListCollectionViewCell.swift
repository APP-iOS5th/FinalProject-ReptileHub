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
        // TODO: ImageSet 삭제하기
        view.image = UIImage(named: "tempImage")
        // TODO: 다른 view에서도 radius사용한 거 있으면 masksToBounds주기
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var GrowthDiaryItemTitle: UILabel = {
        let label = UILabel()
        // TODO: 이름 부분은 bold처리
        label.text = "000 도마뱀"
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    private lazy var GrowthDiaryItemTimeStamp: UILabel = {
        let label = UILabel()
        // TODO: fetch()해올 떄 상태도 받을 수 있는 db 모델 작성 요구
        label.text = "2024. 08. 14 생성"
        label.font = UIFont.systemFont(ofSize: 14)
        // TODO: 색상변경
        label.textColor = .gray
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
        self.addSubview(GrowthDiaryItemImage)
        self.addSubview(GrowthDiaryItemTitle)
        self.addSubview(GrowthDiaryItemTimeStamp)
        
        GrowthDiaryItemImage.snp.makeConstraints { make in
            make.top.equalTo(self)
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
            make.width.height.equalTo(120)
        }
        
        GrowthDiaryItemTitle.snp.makeConstraints { make in
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
            make.top.equalTo(GrowthDiaryItemImage.snp.bottom).offset(10)
        }
        
        GrowthDiaryItemTimeStamp.snp.makeConstraints { make in
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
            make.top.equalTo(GrowthDiaryItemTitle.snp.bottom).offset(3)
        }
    }
}
