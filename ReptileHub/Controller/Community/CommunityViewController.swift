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
    
    private let communityListView = CommunityListView()
    


    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = communityListView
        communityListView.configureTableView(delegate: self, datasource: self)
        view.backgroundColor = .white
        title = "커뮤니티"
        
        setupSearchButton()
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
        return cell
    }
    
    
}
