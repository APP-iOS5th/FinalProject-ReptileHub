//
//  DetailGrowthDiaryViewController.swift
//  ReptileHub
//
//  Created by 이상민 on 9/1/24.
//

import UIKit

class DetailGrowthDiaryViewController: UIViewController {
    private lazy var detailGrowthDiaryView = DetailGrowthDiaryView()
    let tempData = [Int]()
    
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
    
    //데이터를 가져오는 함수
    private func loadData(){
        if tempData.isEmpty{
            let emptyCellView = createEmptyCellView()
            detailGrowthDiaryView.detailAddSepcialNotesCellView(emptyCellView)
        }else{
            for index in 0..<tempData.count{
                let cellView = createCellView(tag: index)
                detailGrowthDiaryView.detailAddSepcialNotesCellView(cellView)
            }
        }
    }
    
    //데이터가 없다는 셀을 만들어 주는 함수
    private func createEmptyCellView() -> UIView{
        let label = UILabel()
        label.text = "데이터가 존재하지 않습니다."
        label.textAlignment = .center
        label.textColor = UIColor.textFieldPlaceholder
        label.backgroundColor = UIColor.groupProfileBG
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        label.snp.makeConstraints { make in
            make.height.equalTo(100)
        }
        return label
    }
    
    //특이사항 셀을 만들어 주는 함수
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
        
        return cell
    }
    
    //셀을 클릭했을 때 디테일 뷰로 이동시켜주는 함수
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
