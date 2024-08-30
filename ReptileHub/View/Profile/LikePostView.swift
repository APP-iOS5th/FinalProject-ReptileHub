//
//  LikePostView.swift
//  ReptileHub
//
//  Created by 육현서 on 8/26/24.
//

import UIKit

class LikePostView: UIView {
    
    private var likePostTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(LikePostTableViewCell.self, forCellReuseIdentifier: "likeCell")
        
        return tableView
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        
        self.addSubview(likePostTableView)
        
        likePostTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configureLikePostTableView(delegate: UITableViewDelegate, datasource: UITableViewDataSource) {
        likePostTableView.delegate = delegate
        likePostTableView.dataSource = datasource
    }
}
