//
//  EmptyVIew.swift
//  ReptileHub
//
//  Created by 이상민 on 8/17/24.
//

import UIKit

class EmptyView: UIView {
    let height: CGFloat?
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.textFieldPlaceholder
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    init(height: CGFloat? = nil) {
        self.height = height
        super.init(frame: .zero)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUp(){
        self.addSubview(emptyLabel)
        
        emptyLabel.snp.makeConstraints { make in
            if let height = self.height{
                make.height.equalTo(height)
            }
            make.edges.equalTo(self)
            make.center.equalTo(self)
        }
    }
    
    func configure(_ message: String){
        self.emptyLabel.text = message
    }
}
