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
    
    //MARK: - 무게를 다시 불러와야 하는지 상태를 나타내는 변수
    private var shouldReloadWeightData = false {
        didSet{
            if shouldReloadWeightData{
                self.fetchWeightData()
                shouldReloadWeightData = false
            }
        }
    }
    
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
    
//    override func vieAppearing(_ animated: Bool) {
//        super.viewIsAppearing(animated)
//        if shouldReloadWeightData{
//            print("업데이틑 됌")
//            self.fetchWeightData()
//            self.shouldReloadWeightData = false
//        }
//    }
    
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
        fetchWeightData()
    }
    
    private func fetchWeightData(){
        DiaryPostService.shared.fetchDailyWeightEntries(userID: UserService.shared.currentUserId, diaryID: diaryID) { [weak self] response in
            switch response{
            case .success(let responseData):
                print("여기가 데이터 입니다.")
                print(responseData)
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
        let addWeightVC = WeightAddViewController(diaryID: diaryID, editMode: false)
        addWeightVC.previousVC = self
        addWeightVC.modalPresentationStyle = .automatic
        addWeightVC.sheetPresentationController?.detents = [.medium(), .large()]
        addWeightVC.sheetPresentationController?.prefersGrabberVisible = true
        addWeightVC.sheetPresentationController?.preferredCornerRadius = 10
        addWeightVC.sheetPresentationController?.animateChanges {
            sheetPresentationController?.selectedDetentIdentifier = .medium
        }
        present(addWeightVC, animated: true)
    }
    
    //MARK: - 업데이트 해야한다는 상태 변경 함수
    func updateWeightData(){
        shouldReloadWeightData = true
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
        cell.editWeightButtonTapped = { [weak self] in
            guard let diaryID = self?.diaryID else { return }
            let editWeightVC = WeightAddViewController(diaryID: diaryID, editMode: true)
            editWeightVC.previousVC = self
            editWeightVC.weightData = self?.weightEntries[indexPath.row]
            editWeightVC.modalPresentationStyle = .automatic
            editWeightVC.sheetPresentationController?.detents = [.medium(), .large()]
            editWeightVC.sheetPresentationController?.prefersGrabberVisible = true
            editWeightVC.sheetPresentationController?.preferredCornerRadius = 10
            editWeightVC.sheetPresentationController?.animateChanges {
                self?.sheetPresentationController?.selectedDetentIdentifier = .medium
            }
            self?.present(editWeightVC, animated: true)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
}
