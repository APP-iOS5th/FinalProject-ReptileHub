//
//  WritePostListView.swift
//  ReptileHub
//
//  Created by 육현서 on 8/26/24.
//

import UIKit
import SnapKit

class WritePostListView: UIView {

    private var WritePostTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(WritePostListTableViewCell.self, forCellReuseIdentifier: "cell")
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
        self.addSubview(WritePostTableView)
        
        WritePostTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configureWritePostTableView(delegate: UITableViewDelegate, datasource: UITableViewDataSource) {
        WritePostTableView.delegate = delegate
        WritePostTableView.dataSource = datasource
    }
}
