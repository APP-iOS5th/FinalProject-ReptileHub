//
//  weightAddEditView.swift
//  ReptileHub
//
//  Created by 이상민 on 9/3/24.
//

import UIKit

class WeightAddEditListView: UIView {
    
    //MARK: - 카테고리 버튼 클로저
    private lazy var categoryButton = { (text: String) -> UIButton in
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        config.title = text
        config.baseBackgroundColor = .red
        button.configuration = config
        return button
    }
    
    //MARK: - 연 버튼
    private lazy var yearCategory = categoryButton("연도")
    //MARK: - 월 버튼
    private lazy var monthCategory = categoryButton("월")
    //MARK: - 일 벝튼
    private lazy var dayCategory = categoryButton("일")
    
    //MARK: - 카테고리 스택 뷰
    private lazy var categoryStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [yearCategory, monthCategory, dayCategory])
        view.axis = .horizontal
        view.spacing = 10
        view.distribution = .fillEqually
        return view
    }()
    
    //MARK: - 무게 추이 테이블 뷰
    private lazy var weightAddEditTableView: UITableView = {
        let view = UITableView()
        return view
    }()
    
    private lazy var mainView: UIView = {
        let view = UIView()
        view.backgroundColor = .yellow
        view.addSubview(categoryStackView)
        view.addSubview(weightAddEditTableView)
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
        self.addSubview(mainView)
        
        mainView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        categoryStackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(mainView)
        }
        
        weightAddEditTableView.snp.makeConstraints { make in
            make.top.equalTo(categoryStackView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func configureWeightAddEditTablview(delegate: UITableViewDelegate, dataSouce: UITableViewDataSource){
        self.weightAddEditTableView.delegate = delegate
        self.weightAddEditTableView.dataSource = dataSouce
    }
    
    func registerWeightAddEditTablCell(_ cellClass: AnyClass?, forCellReuseIdentifier identifier: String) {
        weightAddEditTableView.register(cellClass, forCellReuseIdentifier: identifier)
    }
    
    func reloadWeightAddEditListView(){
        self.weightAddEditTableView.reloadData()
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
