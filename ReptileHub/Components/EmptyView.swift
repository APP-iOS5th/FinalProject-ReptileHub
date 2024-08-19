//
//  EmptyVIew.swift
//  ReptileHub
//
//  Created by 이상민 on 8/17/24.
//

import UIKit

class EmptyView: UIView {
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor(red: 215/255, green: 215/255, blue: 215/255, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUp(){
        self.addSubview(emptyLabel)
        
        emptyLabel.snp.makeConstraints { make in
            make.edges.equalTo(self)
            make.center.equalTo(self)
        }
    }

    func configure(_ message: String){
        self.emptyLabel.text = message
    }
}
