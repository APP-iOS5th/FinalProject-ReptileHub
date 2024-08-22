//
//  CommunityDetailViewController.swift
//  ReptileHub
//
//  Created by 조성빈 on 8/12/24.
//

import UIKit
import SnapKit

class CommunityDetailViewController: UIViewController {

    let detailView = CommunityDetailView()
    
    private var menuButton: UIBarButtonItem = UIBarButtonItem()
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        self.title = "커뮤니티"
        
        setupMenuButton()
        setupDetailView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        detailView.initHeightValue()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        detailView.remakeTableView()
    }

    
    //MARK: - menu 버튼
    private func setupMenuButton() {
        let ellipsisImage = UIImage(systemName: "ellipsis")
        
        // UIButton을 생성하여 회전
        let button = UIButton(type: .system)
        button.setImage(ellipsisImage, for: .normal)
        button.tintColor = .black
        button.transform = CGAffineTransform(rotationAngle: .pi / 2) // 90도 회전
        
        button.addTarget(self, action: #selector(actionMenuButton), for: .touchUpInside)
        
        menuButton = UIBarButtonItem(customView: button)
        
        self.navigationItem.rightBarButtonItem = menuButton
    }
    
    //MARK: - 커뮤니티 디테일 뷰 setup
    private func setupDetailView() {
        self.view = detailView
        detailView.backgroundColor = .white
        detailView.configureTableView(scrollViewDelegate: self, tableViewDelegate: self, tableViewDatasource: self, textViewDelegate: self)
    }
    
    @objc
    private func actionMenuButton() {
        print("메뉴 버튼 클릭.")
    }
    


    
}


extension CommunityDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        detailView.imageScrollCount(scrollView: scrollView)
    }
}

extension CommunityDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        detailView.dummyData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentTableViewCell
        cell.commentText = detailView.dummyData[indexPath.row]
        cell.configureCell()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        detailView.tableViewCellHeight(indexPath: indexPath, tableView: tableView)
    }
}

extension CommunityDetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        detailView.textViewChange(textView: textView)
    }
}
