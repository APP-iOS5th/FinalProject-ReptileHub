//
//  DetailGrowthDiaryViewController.swift
//  ReptileHub
//
//  Created by 이상민 on 9/1/24.
//

import UIKit
import FirebaseAuth

class DetailGrowthDiaryViewController: UIViewController {
    private lazy var detailGrowthDiaryView = DetailGrowthDiaryView()
    private lazy var emptyView: EmptyView = {
        return EmptyView()
    }()
//    private var detailData: GrowthDiaryResponse?
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUP()
        fetchDetailData()
    }
    
    private func setUP(){
        self.title = "반려 도마뱀 프로필"
        self.view = detailGrowthDiaryView
        self.view.backgroundColor = .white
        detailGrowthDiaryView.configureDetailPreviewTableView(delegate: self, dataSource: self)
        detailGrowthDiaryView.registerDetailPreviewTableCell(SpecialListViewCell.self, forCellReuseIdentifier: SpecialListViewCell.identifier)
        //        detailGrowthDiaryView.updateTableViewHeight()
        //        loadData()
        
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
    
    private func showNavigaionSpecialNotes(){
        let showGrowthDiaryToSpeicialNotes = SpecialListViewController()
        self.navigationController?.pushViewController(showGrowthDiaryToSpeicialNotes, animated: true)
    }
    
    private func showNavigationWeightInfo(){
        let showGrowthDiaryToWeightInfo = weightAddEditViewController()
        self.navigationController?.pushViewController(showGrowthDiaryToWeightInfo, animated: true)
    }
    
    // TODO: menu는 성장일지에서 필요가 없으므로 옵셔널로 처리 요청
    // TODO: 테이블 cell의 데이터를 넣는 함수 요청
}

extension DetailGrowthDiaryViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tempData.count == 0{
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
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: 해당 cell에 맞는 디테일 뷰로 넘어가게 수정하기
        self.showNavigaionSpecialNotes()
    }
    
    
}
