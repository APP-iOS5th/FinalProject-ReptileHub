//
//  weightAddEditView.swift
//  ReptileHub
//
//  Created by 이상민 on 9/3/24.
//

import UIKit

class WeightAddEditListView: UIView {
    
    //MARK: - 무게 추이 테이블 뷰
    private lazy var weightAddEditTableView: UITableView = {
        let view = UITableView()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setUI(){
        self.addSubview(weightAddEditTableView)
        
        weightAddEditTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configureWeightAddEditTablview(delegate: UITableViewDelegate, dataSouce: UITableViewDataSource){
        self.weightAddEditTableView.delegate = delegate
        self.weightAddEditTableView.dataSource = dataSouce
    }
    
    func registerWeightAddEditTablCell(_ cellClass: AnyClass?, forCellReuseIdentifier identifier: String) {
        weightAddEditTableView.register(cellClass, forCellReuseIdentifier: identifier)
    }
    
    func weightAddEditViewScrollState(){
        weightAddEditTableView.setNeedsLayout()
        weightAddEditTableView.layoutIfNeeded()
        
        if weightAddEditTableView.contentSize.height > weightAddEditTableView.bounds.height{
            weightAddEditTableView.isScrollEnabled = true
        }else{
            weightAddEditTableView.isScrollEnabled = false
        }
    }

}
