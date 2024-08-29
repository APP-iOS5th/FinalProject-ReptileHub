//
//  CommunityViewController.swift
//  ReptileHub
//
//  Created by 조성빈 on 8/5/24.
//

import UIKit
import SnapKit


class CommunityViewController: UIViewController {
    
    private var fetchTestData: [ThumbnailPostResponse] = []
    
    private var searchButton: UIBarButtonItem = UIBarButtonItem()
    
    private let communityListView = CommunityListView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = communityListView
        
        CommunityService.shared.fetchAllPostThumbnails(forCurrentUser: "R8FK52H2UebtfjNeODkNTEpsOgG3") { result in
            switch result {
            case .success(let thumnails):
                print("차단유저 제외 모든 post 불러오기 성공")
                self.fetchTestData = thumnails
                self.communityListView.communityTableView.reloadData()
            case .failure(let error):
                print("모든 post 불러오기 실패 : \(error.localizedDescription)")
            }
        }

        communityListView.delegate = self
        communityListView.configureTableView(delegate: self, datasource: self)
        view.backgroundColor = .white
        title = "홈"

        setupSearchButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

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

extension CommunityViewController: CommunityListViewDelegate {
    func didTapAddPostButton() {
        let addPostViewController = AddPostViewController()
        addPostViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(addPostViewController, animated: true)
    }
}


extension CommunityViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchTestData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        85
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! CommunityTableViewCell
        cell.testThumbnail = self.fetchTestData[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailViewController = CommunityDetailViewController()
        detailViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
}


