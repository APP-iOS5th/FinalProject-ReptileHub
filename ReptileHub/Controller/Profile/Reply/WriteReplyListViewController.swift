//
//  WriteReplyListViewController.swift
//  Reptile_Hub_UI
//
//  Created by 육현서 on 8/13/24.
//

import UIKit
import SnapKit

class WriteReplyListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var replyListTableView: UITableView = {
       let tableView = UITableView()
        tableView.register(ReplyListTableViewCell.self, forCellReuseIdentifier: "replyCell")
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.title = "내가 작성한 댓글"
        
        replyListTableView.delegate = self
        replyListTableView.dataSource = self
        
        view.addSubview(replyListTableView)
        
        replyListTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        18
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        87
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "replyCell", for: indexPath) as! ReplyListTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
}
