//
//  DetailGrowthDiaryViewController.swift
//  ReptileHub
//
//  Created by 이상민 on 9/1/24.
//

import UIKit
import FirebaseAuth

class DetailGrowthDiaryViewController: UIViewController {
    
    private var shouldReloadDetailData = false
    weak var previousVC: GrowthDiaryViewController?
    private lazy var detailGrowthDiaryView = DetailGrowthDiaryView()
    private lazy var emptyView: EmptyView = {
        return EmptyView()
    }()
    private lazy var detailEitButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(naviagtionEditDetailVC))
        return button
    }()
    
    private var previewSpecialNotesData: [DiaryResponse] = []
    let diaryID: String
    
    init(diaryID: String) {
        self.diaryID = diaryID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let tempData: [Int] = [1,2,3]
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailGrowthDiaryView.updateTableViewHeight()
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        if shouldReloadDetailData{
            fetchDetailData()
            shouldReloadDetailData = false
        }
        fetchSpecialNotesData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUP()
    }
    
    private func setUP(){
        self.title = "반려 도마뱀 프로필"
        self.view = detailGrowthDiaryView
        self.view.backgroundColor = .white
        self.navigationItem.rightBarButtonItem = self.detailEitButton
        fetchDetailData()
        detailGrowthDiaryView.configureDetailPreviewTableView(delegate: self, dataSource: self)
        detailGrowthDiaryView.registerDetailPreviewTableCell(SpecialListViewCell.self, forCellReuseIdentifier: SpecialListViewCell.identifier)

        detailGrowthDiaryView.detailShowSpecialNoteButtonTapped = { [weak self] in
            self?.showNavigaionSpecialNotes()
        }
        detailGrowthDiaryView.detailShowWeightInfoButtonTapped = { [weak self] in
            self?.showNavigationWeightInfo()
        }
    }
    
    private func fetchDetailData(){
        DiaryPostService.shared.fetchGrowthDiaryDetails(userID: UserService.shared.currentUserId, diaryID: diaryID) { [weak self] response in
            switch response{
            case .success(let responseData):
                print("성공")
                self?.detailGrowthDiaryView.configureDetailGrowthDiaryData(detailData: responseData)
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    // TODO: 최대 3개까지 주는건지(2개 있을 경우는 2개만 주는 지)
    private func fetchSpecialNotesData(){
        DiaryPostService.shared.fetchDiaryEntries(userID: UserService.shared.currentUserId, diaryID: diaryID, limit: 3) { [weak self] response in
            switch response{
            case .success(let responseData):
                self?.previewSpecialNotesData = responseData
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func updateDetailDate(){
        self.shouldReloadDetailData = true
    }
    
    private func showNavigaionSpecialNotes(){
        let showGrowthDiaryToSpeicialNotes = SpecialListViewController()
        self.navigationController?.pushViewController(showGrowthDiaryToSpeicialNotes, animated: true)
    }
    
    private func showNavigationWeightInfo(){
        let showGrowthDiaryToWeightInfo = WeightAddEditViewController(diaryID: diaryID)
        self.navigationController?.pushViewController(showGrowthDiaryToWeightInfo, animated: true)
    }
    
    @objc
    private func naviagtionEditDetailVC(){
        let editDetailVC = AddGrowthDiaryViewController(editMode: true)
        editDetailVC.previousViewController = previousVC
        editDetailVC.previousDetailVC = self
        editDetailVC.diaryID = self.diaryID
        self.navigationController?.pushViewController(editDetailVC, animated: true)
    }
    
    // TODO: menu는 성장일지에서 필요가 없으므로 옵셔널로 처리 요청
    // TODO: 테이블 cell의 데이터를 넣는 함수 요청
}

extension DetailGrowthDiaryViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if previewSpecialNotesData.count == 0{
            detailGrowthDiaryView.detailPreviesSpecialNoteTableView.isHidden = true
            detailGrowthDiaryView.emptyview.isHidden = false
        }else{
            detailGrowthDiaryView.detailPreviesSpecialNoteTableView.isHidden = false
            detailGrowthDiaryView.emptyview.isHidden = true
        }
        return tempData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SpecialListViewCell.identifier, for: indexPath) as? SpecialListViewCell else {
            return UITableViewCell()
        }
        // TODO: cell 대입함수 사용하기
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: 해당 cell에 맞는 디테일 뷰로 넘어가게 수정하기
        self.showNavigaionSpecialNotes()
    }
    
    
}
