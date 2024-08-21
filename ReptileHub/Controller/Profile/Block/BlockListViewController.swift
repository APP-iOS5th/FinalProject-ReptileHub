//
//  BlockListViewController.swift
//  Reptile_Hub_UI
//
//  Created by 육현서 on 8/8/24.
//

import UIKit
import SnapKit

class BlockListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var blockUserTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(BlockUserTableViewCell.self, forCellReuseIdentifier: "userCell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.title = "내가 차단한 사용자"
        
        blockUserTableView.delegate = self
        blockUserTableView.dataSource = self
        
        view.addSubview(blockUserTableView)
        
        
        blockUserTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // 테이블 뷰의 셀 수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        18
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        68
    }
    
    // 각 테이블 뷰의 셀 구성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! BlockUserTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    // 테이블 뷰의 셀 선택 시 처리 (선택 사항)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected User Row: \(indexPath.row + 1)")
    }
}
