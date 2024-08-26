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
        return cell
    }
}
