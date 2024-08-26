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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view = specialListView
        specialListView.configureTableView(delegate: self, datasource: self)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "SpecialCell", for: indexPath)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let specialDetailViewController = SpecialDetailViewController()
        self.navigationController?.pushViewController(specialDetailViewController, animated: true)
    }
    
}
