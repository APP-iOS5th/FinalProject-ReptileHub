//
//  DetailGrowthDiaryViewController.swift
//  ReptileHub
//
//  Created by 이상민 on 9/1/24.
//

import UIKit

class DetailGrowthDiaryViewController: UIViewController {
    private lazy var detailGrowthDiaryView = DetailGrowthDiaryView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUP()
    }
    
    private func setUP(){
        self.title = "반려 도마뱀 프로필"
        self.view = detailGrowthDiaryView
        self.view.backgroundColor = .white
        loadData()
        detailGrowthDiaryView.detailShowSpecialNoteButtonTapped = { [weak self] in
            self?.showNavigaionSpecialNotes()
        }
    }
    
    private func showNavigaionSpecialNotes(){
        let showGrowthDiaryToSpeicialNotes = SpecialListViewController()
        self.navigationController?.pushViewController(showGrowthDiaryToSpeicialNotes, animated: true)
    }
    
    private func loadData(){
        for index in 0..<3{
            let cellView = createCellView(tag: index)
            detailGrowthDiaryView.detailAddSepcialNotesCellView(cellView)
        }
    }
    
    private func createCellView(tag: Int) -> UIView {
        // CustomTableViewCell 생성
        let cell = SpecialListViewCell(style: .default, reuseIdentifier: SpecialListViewCell.identifier)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped(_:)))
        cell.contentView.addGestureRecognizer(tapGesture)
        cell.contentView.isUserInteractionEnabled = true
        cell.contentView.tag = tag
        
        // 셀의 높이를 설정
        cell.contentView.snp.makeConstraints { make in
            make.height.equalTo(100)
        }
        
        return cell.contentView
    }
    
    @objc
    private func cellTapped(_ sender: UITapGestureRecognizer){
        if let tag = sender.view?.tag{
            print("\(tag)번 셀의 디테일 뷰로 이동합니다.")
        }
        
        let showGrowthDiaryToSepcialDetail = SpecialDetailViewController()
        self.navigationController?.pushViewController(showGrowthDiaryToSepcialDetail, animated: true)
    }
    
    // TODO: menu는 성장일지에서 필요가 없으므로 옵셔널로 처리 요청
    // TODO: 테이블 cell의 데이터를 넣는 함수 요청
}
