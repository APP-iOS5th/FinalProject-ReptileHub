//
//  DetailGrowthDiaryViewController.swift
//  ReptileHub
//
//  Created by 이상민 on 9/1/24.
//

import UIKit

class DetailGrowthDiaryViewController: UIViewController {
    private lazy var detailGrowthDiaryView = DetailGrowthDiaryView()
    private lazy var emptyView: EmptyView = {
        return EmptyView()
    }()
    
    let tempData: [Int] = [1,2,3]
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailGrowthDiaryView.updateTableViewHeight()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUP()
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
        
    }
    
    private func showNavigaionSpecialNotes(){
        let showGrowthDiaryToSpeicialNotes = SpecialListViewController()
        self.navigationController?.pushViewController(showGrowthDiaryToSpeicialNotes, animated: true)
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
