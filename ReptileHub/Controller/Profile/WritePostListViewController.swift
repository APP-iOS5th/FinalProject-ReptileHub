//
//  WritePostListViewController.swift
//  Reptile_Hub_UI
//
//  Created by 육현서 on 8/8/24.
//

import UIKit

class WritePostListViewController: UIViewController {
    
    private let writePostListView = WritePostListView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.title = "내가 작성한 게시글"
        
        self.view = writePostListView
        
        writePostListView.configureWritePostTableView(delegate: self, datasource: self)
        
    }
}

extension WritePostListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        18
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        85
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! WritePostListTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        let menuItems = [
            UIAction(title: "삭제하기", image: UIImage(systemName: "trash"),attributes: .destructive,handler: { _ in}),
        ]
        // UIMenu title 설정
        let menu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: menuItems)
        // 셀에 메뉴 설정
        cell.configure(with: menu)
        
        return cell
    }
}
