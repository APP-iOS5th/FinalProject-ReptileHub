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
    
    var sampleSpecialNoteData = SampleSpecialNoteData()
    
    private var headerHeight = 100.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = specialListView
        sampleSpecialNoteData.createSampleSpecialEntryData()
        specialListView.configureTableView(delegate: self, datasource: self)
        // UIMenu 관련 셀 호출
        specialListView.registerCell(SpecialListViewCell.self, forCellReuseIdentifier: SpecialListViewCell.identifier)
        view.backgroundColor = .white
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        title = "특이사항"
    }
    

}
//MARK: - TableView 관련
extension SpecialListViewController: UITableViewDelegate, UITableViewDataSource {

    // 셀 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 10
        sampleSpecialNoteData.specialEntries.count
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
        // UIMenu UIAction 설정
        let menuItems = [
                UIAction(title: "삭제하기", image: UIImage(systemName: "trash"),attributes: .destructive,handler: { _ in}),
                ]
        // UIMenu title 설정
        let menu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: menuItems)
        // 셀에 메뉴 설정
        let specialEntry = sampleSpecialNoteData.specialEntries[indexPath.row]
        cell.configureCell(specialEntry: specialEntry)
        cell.configure(with: menu)
        cell.selectionStyle = .none
        return cell
    }
    // 셀 기능
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let specialEntry = sampleSpecialNoteData.specialEntries[indexPath.row]
        let specialDetailViewController = SpecialDetailViewController(saverEntries: specialEntry)
//        self.navigationController?.pushViewController(specialDetailViewController, animated: true)
        show(specialDetailViewController, sender: self)
    }
    // 헤더 뷰 호출
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let specialPlusButtonView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SpecialPlusButtonView.identifier) as? SpecialPlusButtonView else {
                    return UIView()
                }
        // 버튼 액션 설정
        specialPlusButtonView.buttonAction = { [weak self] in
            let specialEditViewController = SpecialEditViewController()
            self?.navigationController?.pushViewController(specialEditViewController, animated: true)
        }
        return specialPlusButtonView
    }
    @objc private func addSpecialNote() {
        let specialEditViewController = SpecialEditViewController()
//        let navController = UINavigationController(rootViewController: SpecialEditViewController)
//        specialEditViewController.delegate = self
//        present(navController, animated: true)
    }
    
    
}
