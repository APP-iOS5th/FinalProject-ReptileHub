//
//  CommunityListView.swift
//  ReptileHub
//
//  Created by 조성빈 on 8/19/24.
//

import UIKit

// addpostviewcontroller 뷰 이동 버튼액션
protocol CommunityListViewDelegate: AnyObject {
    func didTapAddPostButton()
}

class CommunityListView: UIView {
    // 테스트 중~
    var testData: [ThumbnailPostResponse] = []

    weak var delegate: CommunityListViewDelegate?

    let communityTableView: UITableView = UITableView(frame: .zero)
    
    let addButton: UIButton = UIButton(type: .custom)
    

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupTableView()
        setupAddButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    

    //MARK: - communityTableView set up
    private func setupTableView() {
        communityTableView.register(CommunityTableViewCell.self, forCellReuseIdentifier: "listCell")
        
        self.addSubview(communityTableView)
        
        communityTableView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(self.snp.leading)
            make.trailing.equalTo(self.snp.trailing)
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
        }

    }

    //MARK: - Add Button set up
    private func setupAddButton() {
        addButton.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        addButton.layer.cornerRadius = addButton.frame.width * 0.5
        addButton.setImage(UIImage(systemName: "pencil"), for: .normal)
        addButton.backgroundColor = .addBtnGraphTabbar
        addButton.tintColor = .white

        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        self.addSubview(addButton)
        
        addButton.snp.makeConstraints { make in
            make.trailing.equalTo(self.snp.trailing).offset(-20)
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.width.height.equalTo(60)
        }
    }
    

    @objc private func addButtonTapped() {
            delegate?.didTapAddPostButton()
        }
    
    
    func configureTableView(delegate: UITableViewDelegate, datasource: UITableViewDataSource) {
        communityTableView.delegate = delegate
        communityTableView.dataSource = datasource
    }
}
