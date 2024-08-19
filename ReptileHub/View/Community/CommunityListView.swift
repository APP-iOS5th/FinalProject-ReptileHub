//
//  CommunityListView.swift
//  ReptileHub
//
//  Created by 조성빈 on 8/19/24.
//

import UIKit

class CommunityListView: UIView {

    private var communityTableView: UITableView = UITableView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTableView()
    }
    
    //MARK: - communityTableView set up
    private func setupTableView() {
        communityTableView.backgroundColor = .yellow
        
        communityTableView.register(CommunityTableViewCell.self, forCellReuseIdentifier: "listCell")
        
        self.addSubview(communityTableView)
        
        communityTableView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(self.snp.leading)
            make.trailing.equalTo(self.snp.trailing)
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
        }

    }
    
    private func configureTableView(delegate: UITableViewDelegate, datasource: UITableViewDataSource) {
        communityTableView.delegate = delegate
        communityTableView.dataSource = datasource
    }
}
