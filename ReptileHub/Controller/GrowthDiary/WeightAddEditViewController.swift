//
//  weightAddEditViewController.swift
//  ReptileHub
//
//  Created by 이상민 on 9/4/24.
//

import UIKit

class WeightAddEditViewController: UIViewController {

    private lazy var weightAddEditView = WeightAddEditListView()
    
    private let diaryID: String
    private var weightEntries: [WeightEntry] = []
    
    init(diaryID: String) {
        self.diaryID = diaryID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(moveAddWeightController))
        return button
    }()
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        fetchWeightData()        
    }
    
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
    
    private func fetchWeightData(){
        DiaryPostService.shared.fetchDailyWeightEntries(userID: UserService.shared.currentUserId, diaryID: diaryID) { [weak self] response in
            switch response{
            case .success(let responseData):
                self?.weightEntries = responseData
                self?.weightAddEditView.reloadWeightAddEditListView()
            case .failure(let error):
                print("ERROR: \(error.localizedDescription)")
            }
        }
    }
    
    //무게 추가하는 뷰 컨트롤러로 이동 액션
    @objc
    private func moveAddWeightController(){
        let addWeightVC = WeightAddViewController()
        addWeightVC.modalPresentationStyle = .automatic
        addWeightVC.sheetPresentationController?.detents = [.medium(), .large()]
        addWeightVC.sheetPresentationController?.prefersGrabberVisible = true
        addWeightVC.sheetPresentationController?.preferredCornerRadius = 10
        addWeightVC.sheetPresentationController?.animateChanges {
            sheetPresentationController?.selectedDetentIdentifier = .medium
        }
        present(addWeightVC, animated: true)
    }
}

extension WeightAddEditViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weightEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WeightAddEditViewCell.identifier, for: indexPath) as? WeightAddEditViewCell else {
                return UITableViewCell()
            }
        cell.selectionStyle = .none
        cell.configureWeightCell(weightEntry: weightEntries[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
}
