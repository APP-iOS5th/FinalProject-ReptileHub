//
//  weightAddEditView.swift
//  ReptileHub
//
//  Created by 이상민 on 9/3/24.
//

import UIKit

class weightAddEditListView: UIView {
    
    //MARK: - 무게 추이 테이블 뷰
    private lazy var weightAddEditTableView = {
        let view = UITableView()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
}
