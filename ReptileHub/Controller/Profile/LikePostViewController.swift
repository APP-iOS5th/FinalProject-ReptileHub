//
//  LikePostViewController.swift
//  Reptile_Hub_UI
//
//  Created by 육현서 on 8/8/24.
//

import UIKit

class LikePostViewController: UIViewController {
    
    private let likePostView = LikePostView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.title = "내가 찜한 게시글"
        
        self.view = likePostView
        
        likePostView.configureLikePostTableView(delegate: self, datasource: self)
    }
}


extension LikePostViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        18
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        85
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "likeCell", for: indexPath) as! LikePostTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
}
