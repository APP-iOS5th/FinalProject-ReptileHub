//
//  SpecialPlusButtonView.swift
//  ReptileHub
//
//  Created by 황민경 on 8/21/24.
//

import UIKit
import SnapKit

class SpecialPlusButtonView: UITableViewHeaderFooterView {
    
    //MARK: SpecialListView 상단 버튼
    static let identifier = "SpecialPlusButton"
    private var heightConstraint: Constraint?
    private var plusButtonBottomConstraint: Constraint?
    
    //MARK: SpecialPlusButton 정의
    private var plusButton: UIButton = {
        let plusButton = UIButton()
        plusButton.setTitle("+", for: .normal)
        plusButton.titleLabel?.font = UIFont.systemFont(ofSize: 40)
        plusButton.backgroundColor = UIColor(named: "profileSegmentBG")
        plusButton.setTitleColor(.white, for: .normal)
        plusButton.layer.cornerRadius = 5
        return plusButton
    }()
    //MARK: 버튼 액션 정의
    var buttonAction: (() -> Void)?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI2()
        
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: 버튼 실행 함수
    @objc private func plusButtonTapped() {
            buttonAction?()  // 버튼이 눌렸을 때 액션 실행
        }
    
    //MARK: 버튼 레이아웃
    private func setupUI2() {
        backgroundColor = .white
        addSubview(plusButton)
        
        plusButton.snp.makeConstraints{(make) in
            make.width.equalTo(contentView).offset(-30)
            make.centerX.equalTo(contentView)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().inset(10)
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
        }
    }

}
