//
//  WriteReplyListView.swift
//  ReptileHub
//
//  Created by 육현서 on 8/26/24.
//

import UIKit

class WriteReplyListView: UIView {
    
    var replyListTableView: UITableView = {
       let tableView = UITableView()
        tableView.register(WriteReplyListTableViewCell.self, forCellReuseIdentifier: "replyCell")
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
        
        self.addSubview(replyListTableView)
        
        replyListTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configureReplyTableView(delegate: UITableViewDelegate, datasource: UITableViewDataSource) {
        replyListTableView.delegate = delegate
        replyListTableView.dataSource = datasource
    }
}
