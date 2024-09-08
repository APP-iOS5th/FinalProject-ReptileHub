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
    let lizardName: String
    
    init(diaryID: String, lizardName: String) {
        self.diaryID = diaryID
        self.lizardName = lizardName
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
        fetchMonthWeightData()
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
        fetchSpecialNotesData()
        fetchMonthWeightData()
        detailGrowthDiaryView.configureDetailPreviewTableView(delegate: self, dataSource: self)
        detailGrowthDiaryView.registerDetailPreviewTableCell(SpecialListViewCell.self, forCellReuseIdentifier: SpecialListViewCell.identifier)

        detailGrowthDiaryView.detailShowSpecialNoteButtonTapped = { [weak self] in
            self?.showNavigaionSpecialNotes()
        }
        detailGrowthDiaryView.detailShowWeightInfoButtonTapped = { [weak self] in
            self?.showNavigationWeightInfo()
        }
        detailGrowthDiaryView.deleteButtonTapped = { [weak self] in
            self?.deleteAlertGrowthDiaryView()
        }
    }
    
    private func fetchDetailData(){
        DiaryPostService.shared.fetchGrowthDiaryDetails(userID: UserService.shared.currentUserId, diaryID: diaryID) { [weak self] response in
            switch response{
            case .success(let responseData):
                self?.detailGrowthDiaryView.configureDetailGrowthDiaryData(detailData: responseData)
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchMonthWeightData(){
        DiaryPostService.shared.fetchMonthlyWeightAverages(userID: UserService.shared.currentUserId, diaryID: diaryID) { [weak self] response in
            switch response{
            case .success(let responseData):
                self?.detailGrowthDiaryView.detailWeightChartData(data: responseData)
            case .failure(let error):
                print("ERROR: \(error.localizedDescription)")
            }
        }
    }

    private func fetchSpecialNotesData(){
        DiaryPostService.shared.fetchDiaryEntries(userID: UserService.shared.currentUserId, diaryID: diaryID, limit: 3) { [weak self] response in
            switch response{
            case .success(let responseData):
                self?.previewSpecialNotesData = responseData
                self?.detailGrowthDiaryView.detailPreviesSpecialNoteTableView.reloadData()
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: - 삭제 버튼 클릭 시 alert창 띄우기
    private func deleteAlertGrowthDiaryView(){
        print("이거 실행돼?")
        let title = "성장일지 삭제"
        
        let attributedTitle = NSAttributedString(string: title, attributes: [NSAttributedString.Key.foregroundColor : UIColor.red])
        let alert = UIAlertController(title: "", message: "해당 성장일지를 정말 삭제하시겠습니까?", preferredStyle: .alert)
        alert.setValue(attributedTitle, forKey: "attributedTitle")
        
        let action = UIAlertAction(title: "삭제", style: .destructive){ [weak self] action in
            self?.deleteGrowthDiaryView()
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(cancel)
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - 삭제를 눌렀을 때
    private func deleteGrowthDiaryView(){
        DiaryPostService.shared.deleteGrowthDiary(userID: UserService.shared.currentUserId, diaryID: diaryID) { [weak self] error in
            if let error = error{
                print("ERROR: \(error.localizedDescription)")
            }else{
                if let previousVC = self?.previousVC{
                    previousVC.updateImage()
                }
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func updateDetailDate(){
        self.shouldReloadDetailData = true
    }
    
    private func showNavigaionSpecialNotes(){
        let showGrowthDiaryToSpeicialNotes = SpecialListViewController(diaryID: diaryID, lizardName: lizardName)
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
}

extension DetailGrowthDiaryViewController: UITableViewDelegate, UITableViewDataSource, SpecialDetailViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if previewSpecialNotesData.count == 0{
            detailGrowthDiaryView.detailPreviesSpecialNoteTableView.isHidden = true
            detailGrowthDiaryView.emptyview.isHidden = false
        }else{
            detailGrowthDiaryView.detailPreviesSpecialNoteTableView.isHidden = false
            detailGrowthDiaryView.emptyview.isHidden = true
        }
        return previewSpecialNotesData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SpecialListViewCell.identifier, for: indexPath) as? SpecialListViewCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.configureCell(specialEntry: previewSpecialNotesData[indexPath.item])
        cell.deleteButton.isHidden = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let specialNotesDetailVC = SpecialDetailViewController(saverEntries: previewSpecialNotesData[indexPath.item], diaryID: diaryID, lizardName: lizardName)
        specialNotesDetailVC.delegate = self
        self.navigationController?.pushViewController(specialNotesDetailVC, animated: true)
    }
    
    func deleteSpecialNoteButtonTapped(data: DiaryResponse) {
        DiaryPostService.shared.deleteDiaryEntry(userID: UserService.shared.currentUserId, diaryID: diaryID, entryID: data.entryID) { [weak self] error in
            if let error = error {
                print("ERROR: \(error.localizedDescription)")
            }else{
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
}
