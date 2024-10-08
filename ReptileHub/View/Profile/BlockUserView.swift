//
//  BlockUserView.swift
//  ReptileHub
//
//  Created by 육현서 on 8/24/24.
//

import UIKit
import SnapKit

class BlockUserView: UIView {
    
    // 차단 유저 테이블 뷰
    private (set) var blockUserTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(BlockUserTableViewCell.self, forCellReuseIdentifier: "userCell")
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
        self.addSubview(blockUserTableView)
        blockUserTableView.backgroundColor = .white
        blockUserTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configureBlockUserTableView(delegate: UITableViewDelegate, datasource: UITableViewDataSource) {
        blockUserTableView.delegate = delegate
        blockUserTableView.dataSource = datasource
    }
}
