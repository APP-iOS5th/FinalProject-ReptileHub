//
//  DetailGrowthDiaryViewController.swift
//  ReptileHub
//
//  Created by 이상민 on 9/1/24.
//

import UIKit

class DetailGrowthDiaryViewController: UIViewController {
    private lazy var detailGrowthDiaryView = DetailGrowthDiaryView()
    private let tempData = [1,2,3]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUP()
    }
    
    private func setUP(){
        self.title = "반려 도마뱀 프로필"
        self.view = detailGrowthDiaryView
        self.view.backgroundColor = .white
//        detailGrowthDiaryView.detailConfiguteTablewDelegate(delegate: self, dataSource: self)
        detailGrowthDiaryView.detailShowSpecialNoteButtonTapped = { [weak self] in
            self?.showNavigaionSpecialNotes()
        }
    }
    
    private func showNavigaionSpecialNotes(){
        let showGrowthDiaryToSpeicialNotes = SpecialListViewController()
        self.navigationController?.pushViewController(showGrowthDiaryToSpeicialNotes, animated: true)
    }
}

extension DetailGrowthDiaryViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(tempData.count)
        return tempData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SpecialListViewCell.identifier, for: indexPath) as? SpecialListViewCell else {
            return UITableViewCell()
        }
        
        // TODO: menu는 성장일지에서 필요가 없으므로 옵셔널로 처리 요청
        // TODO: 테이블 cell의 데이터를 넣는 함수 요청
        cell.selectionStyle = .none
        return cell
    }
}
