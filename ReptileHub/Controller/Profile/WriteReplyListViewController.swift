//
//  WriteReplyListViewController.swift
//  Reptile_Hub_UI
//
//  Created by 육현서 on 8/13/24.
//

import UIKit

class WriteReplyListViewController: UIViewController {
    
    private let writeReplyView = WriteReplyListView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.title = "내가 작성한 댓글"

        self.view = writeReplyView
        
        writeReplyView.configureReplyTableView(delegate: self, datasource: self)
    }
}

extension WriteReplyListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        18
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        87
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "replyCell", for: indexPath) as! WriteReplyListTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
}
