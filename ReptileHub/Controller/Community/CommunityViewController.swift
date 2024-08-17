//
//  CommunityViewController.swift
//  ReptileHub
//
//  Created by 조성빈 on 8/5/24.
//

import UIKit
import SnapKit

class CommunityViewController: UIViewController {
    
    private var searchButton: UIBarButtonItem = UIBarButtonItem()
    
    private var communityTableView: UITableView = UITableView(frame: .zero)


    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        title = "커뮤니티"
        
        setupSearchButton()
        setupTableView()
    }
    
    //MARK: - rightBarButtonItem 적용
    private func setupSearchButton() {
        searchButton = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(actionSearchButton))
        
        self.navigationItem.rightBarButtonItem = searchButton
    }
    
    @objc
    private func actionSearchButton() {
        print("돋보기 버튼 클릭.")
    }
    
    //MARK: - communityTableView set up
    private func setupTableView() {
        communityTableView.backgroundColor = .yellow
        
        communityTableView.delegate = self
        communityTableView.dataSource = self
        
        communityTableView.register(CommunityTableViewCell.self, forCellReuseIdentifier: "listCell")
        
        self.view.addSubview(communityTableView)
        
        communityTableView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(self.view.snp.leading)
            make.trailing.equalTo(self.view.snp.trailing)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }

    }


}

extension CommunityViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        18
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        76
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! CommunityTableViewCell
//        cell.setupThumbnail()
        return cell
    }
    
    
}
