//
//  WritePostListView.swift
//  ReptileHub
//
//  Created by 육현서 on 8/26/24.
//

import UIKit
import SnapKit

class WritePostListView: UIView {

    // 내가 쓴 게시글 테이블 뷰
    private (set) var WritePostTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CommunityTableViewCell.self, forCellReuseIdentifier: "cell")
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
