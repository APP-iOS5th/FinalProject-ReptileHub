//
//  weightAddEditViewController.swift
//  ReptileHub
//
//  Created by 이상민 on 9/4/24.
//

import UIKit

class weightAddEditViewController: UIViewController {

    private lazy var weightAddEditView = WeightAddEditListView()    
    
    private lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
        return button
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        weightAddEditView.weightAddEditViewScrollState()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    private func setUI(){
        self.title = "무게 추이"
        self.view = weightAddEditView
        self.view.backgroundColor = .white
        self.navigationItem.rightBarButtonItem = self.addButton
        weightAddEditView.configureWeightAddEditTablview(delegate: self, dataSouce: self)
        weightAddEditView.registerWeightAddEditTablCell(WeightAddEditViewCell.self, forCellReuseIdentifier: WeightAddEditViewCell.identifier)
    }
    
    //무게 추가하는 뷰 컨트롤러로 이동 액션
    private func moveAddWeightController(){
        
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
