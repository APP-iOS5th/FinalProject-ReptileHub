//
//  SpecialListViewController.swift
//  ReptileHub
//
//  Created by 황민경 on 8/26/24.
//

import UIKit
import SnapKit

class SpecialListViewController: UIViewController {
    
    private let specialListView = SpecialListView()
    
    private var headerHeight = 100.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = specialListView
        specialListView.configureTableView(delegate: self, datasource: self)
        // UIMenu 관련 셀 호출
        specialListView.registerCell(SpecialListViewCell.self, forCellReuseIdentifier: SpecialListViewCell.identifier)
        view.backgroundColor = .white
        title = "특이사항"
        
    }

}

extension SpecialListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SpecialListViewCell.identifier, for: indexPath) as? SpecialListViewCell else {
                return UITableViewCell()
            }
        // UIMenu UIAction 설정
        let menuItems = [
                UIAction(title: "삭제하기", image: UIImage(systemName: "trash"),attributes: .destructive,handler: { _ in}),
                ]
        // UIMenu title 설정
        let menu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: menuItems)
        // 셀에 메뉴 설정
        cell.configure(with: menu)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let specialDetailViewController = SpecialDetailViewController()
        self.navigationController?.pushViewController(specialDetailViewController, animated: true)
    }
    
}
