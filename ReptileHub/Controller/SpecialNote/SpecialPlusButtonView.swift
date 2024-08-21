//
//  SpecialPlusButtonView.swift
//  ReptileHub
//
//  Created by 황민경 on 8/21/24.
//

import UIKit
import SnapKit

class SpecialPlusButtonView: UITableViewHeaderFooterView {
    
    static let identifier = "SpecialPlusButton"
//    private var heightConstraint: Constraint?
    private var plusButtonBottomConstraint: Constraint?
    
    private var plusButton: UIButton = {
        let plusButton = UIButton()
        plusButton.setTitle("+", for: .normal)
        plusButton.titleLabel?.font = UIFont.systemFont(ofSize: 40)
        plusButton.backgroundColor = UIColor(named: "Light_Green")
        plusButton.setTitleColor(.white, for: .normal)
        plusButton.layer.cornerRadius = 5
        return plusButton
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI2()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupUI2() {
        
        addSubview(plusButton)
        
//        self.snp.makeConstraints { make in
//            self.heightConstraint = make.height.equalTo(220).constraint // 초기 높이 설정 및 저장
//        }
        
        plusButton.snp.makeConstraints{(make) in
            make.width.equalTo(contentView).offset(-30)
            make.centerX.equalTo(contentView)
//            make.height.equalTo(90)
            make.bottom.equalToSuperview().inset(10)
            self.plusButtonBottomConstraint = make.bottom.equalToSuperview().inset(10).constraint
//            make.top.equalTo(safeAreaLayoutGuide.snp.top)
        }
        
    }
    
//    func updateHeight(height: CGFloat) {
//        var newFrame = frame
//        newFrame.size.height = height
//        frame = newFrame
//        plusButtonBottomConstraint?.update(inset: 10)
//        layoutIfNeeded()
//        heightConstraint?.update(offset: height)
        // 버튼의 위치를 업데이트
//        plusButton.snp.updateConstraints { make in
//            make.bottom.equalToSuperview().inset(10)
//        }
//    }
    //    override func viewDidLoad() {
    //        super.viewDidLoad()
    //
    //
    //    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
