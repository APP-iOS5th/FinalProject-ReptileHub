//
//  weightAddEditViewController.swift
//  ReptileHub
//
//  Created by 이상민 on 9/4/24.
//

import UIKit

class weightAddEditViewController: UIViewController {

    private lazy var weightAddEditView = WeightAddEditListView()    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "무게 추이"
        self.view = weightAddEditView
        self.view.backgroundColor = .white
        weightAddEditView.configureWeightAddEditTablview(delegate: self, dataSouce: self)
        weightAddEditView.registerWeightAddEditTablCell(WeightAddEditViewCell.self, forCellReuseIdentifier: WeightAddEditViewCell.identifier)
        
    }
}

extension weightAddEditViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WeightAddEditViewCell.identifier, for: indexPath) as? WeightAddEditViewCell else {
                return UITableViewCell()
            }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
}
