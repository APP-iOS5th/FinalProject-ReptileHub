//
//  weightAddEditViewCell.swift
//  ReptileHub
//
//  Created by 이상민 on 9/3/24.
//

import UIKit

class WeightAddEditViewCell: UITableViewCell {
    
    static let identifier = "WeightAddEditListCell"
    
    var editWeightButtonTapped: (() -> Void)?
    
    //MARK: - 무게 값 라벨
    private lazy var  weightAddEditViewCellWeightLabel: UILabel = {
        let label = UILabel()
        label.text = "무게 : 6g"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.textFieldTitle
        return label
    }()
    
    //MARK: - 날짜 라벨
    private lazy var  weightAddEditViewCellDateLabel: UILabel = {
        let label = UILabel()
        label.text = Date().formatted
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.textFieldTitle
        return label
    }()
    
    //MARK: - 편집 버튼
    private lazy var weightAddEditViewCellEditButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        
        config.title = "편집"
        config.baseForegroundColor = UIColor.textFieldTitle
        config.imagePlacement = .trailing
        config.attributedTitle?.font = UIFont.systemFont(ofSize: 14)
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        button.configuration = config
        button.contentHorizontalAlignment = .trailing
        button.addAction(UIAction{ [weak self] _ in
            self?.editWeightButtonTapped?()
        }, for: .touchUpInside)
        
        return button
    }()
    
    //MARK: - 모든 서브 뷰를 포함하는 StackView
    private lazy var weightAddEditStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [weightAddEditViewCellDateLabel, weightAddEditViewCellWeightLabel, weightAddEditViewCellEditButton])
        view.axis = .horizontal
        view.distribution = .fillEqually
        return view
    }()
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
    }
    
    private func setUI(){
        
        self.contentView.addSubview(weightAddEditStackView)
        
        weightAddEditStackView.snp.makeConstraints { make in
            make.leading.equalTo(self.contentView.snp.leading).offset(Spacing.mainSpacing)
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-Spacing.mainSpacing)
            make.centerY.equalTo(self.contentView)
        }
    }
    
    func configureWeightCell(weightEntry: WeightEntry){
        weightAddEditViewCellDateLabel.text = weightEntry.date.formatted
        weightAddEditViewCellWeightLabel.text = "무게 : \(weightEntry.weight)kg"
    }
}
