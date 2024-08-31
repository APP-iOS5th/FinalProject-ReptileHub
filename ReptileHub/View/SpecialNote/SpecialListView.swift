//
//  SpecialList.swift
//  ReptileHub
//
//  Created by 황민경 on 8/26/24.
//

import UIKit
import SnapKit

class SpecialListView: UIView {

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SpecialCell")
        
        return tableView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTableView() {
        self.addSubview(tableView)
        
        tableView.snp.makeConstraints{(make) in
            make.top.equalTo(self.safeAreaLayoutGuide)
            make.bottom.equalTo(self)
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
        }
    }
    
    func configureTableView(delegate: UITableViewDelegate, datasource: UITableViewDataSource) {
        tableView.delegate = delegate
        tableView.dataSource = datasource
        tableView.separatorStyle = .none // 셀 선 제거
        tableView.register(SpecialListViewCell.self, forCellReuseIdentifier: "SpecialCell")
    }
    
    // UIMenu tableView에 대한 셀 등록 기능을 제공하는 메서드 추가
    func registerCell(_ cellClass: AnyClass?, forCellReuseIdentifier identifier: String) {
        tableView.register(cellClass, forCellReuseIdentifier: identifier)
    }
    
    func pizza() {
        tableView.layoutIfNeeded()
        tableView.setNeedsLayout()
    }
}