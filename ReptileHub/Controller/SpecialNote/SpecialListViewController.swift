//
//  SpecialListViewController.swift
//  ReptileHub
//
//  Created by 황민경 on 8/26/24.
//

import UIKit
import SnapKit

class SpecialListViewController: UIViewController {
    private let specialListView = SpecialListView()
    
    private var specialListData: [DiaryResponse] = []
    
    var diaryID: String
    
    init(diaryID: String) {
            self.diaryID = diaryID
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    
    private var headerHeight = 100.0
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        fetchSpecialList()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = specialListView
        specialListView.configureTableView(delegate: self, datasource: self)
        // UIMenu 관련 셀 호출
        specialListView.registerCell(SpecialListViewCell.self, forCellReuseIdentifier: SpecialListViewCell.identifier)
        view.backgroundColor = .white
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        title = "특이사항"
    }
    func fetchSpecialList() {
        DiaryPostService.shared.fetchDiaryEntries(userID: UserService.shared.currentUserId, diaryID: diaryID) { [weak self] response in
            switch response{
            case .success(let specialListData):
                self?.specialListData = specialListData
                self?.specialListView.tableView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
            
        }
    }

}
//MARK: - TableView 관련
extension SpecialListViewController: UITableViewDelegate, UITableViewDataSource, SpecialDetailViewDelegate {
    // SpecialEditView 삭제 함수
    func deleteSpecialNoteButtonTapped(data: DiaryResponse) {
        DiaryPostService.shared.deleteDiaryEntry(userID: UserService.shared.currentUserId, diaryID: diaryID, entryID: data.entryID) { [weak self] error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("삭제 완료")
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // 셀 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 10
        specialListData.count
    }
    // 셀 높이
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    // 셀 호출
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SpecialListViewCell.identifier, for: indexPath) as? SpecialListViewCell else {
                return UITableViewCell()
            }
        // UIMenu UIAction 설정 (셀 삭제)
        let menuItems = [
            UIAction(title: "삭제하기", image: UIImage(systemName: "trash"),attributes: .destructive,handler: { [weak self] _ in
                guard let entryID = self?.specialListData[indexPath.row].entryID, let diaryID = self?.diaryID else {
                    return
                }
                DiaryPostService.shared.deleteDiaryEntry(userID: UserService.shared.currentUserId, diaryID: diaryID, entryID: entryID) { [weak self] error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        print("삭제 완료")
                        self?.fetchSpecialList()
                        self?.specialListView.tableView.reloadData()
                    }
                } 
            }),
                ]
        // UIMenu title 설정
        let menu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: menuItems)
        // 셀에 메뉴 설정
        let specialEntry = specialListData[indexPath.row]
        cell.configureCell(specialEntry: specialEntry)
        cell.configure(with: menu)
        cell.selectionStyle = .none
        return cell
    }
    // 셀 기능
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let specialEntry = specialListData[indexPath.row]
        let specialDetailViewController = SpecialDetailViewController(saverEntries: specialEntry, diaryID: diaryID)
        specialDetailViewController.delegate = self
        show(specialDetailViewController, sender: self)
    }
    func deleteSpecialNoteButtonTapped() {
        
    }
    // 헤더 뷰 호출
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let specialPlusButtonView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SpecialPlusButtonView.identifier) as? SpecialPlusButtonView else {
                    return UIView()
                }
        // 버튼 액션 설정
        specialPlusButtonView.buttonAction = { [weak self] in
            guard let diaryID = self?.diaryID else {return}
            let specialEditViewController = SpecialEditViewController(diaryID: diaryID, editMode: false)
            self?.navigationController?.pushViewController(specialEditViewController, animated: true)
        }
        return specialPlusButtonView 
    }
    
    
    
}
