//
//  SpecialListViewController.swift
//  ReptileHub
//
//  Created by 황민경 on 8/21/24.
//

import UIKit
import SnapKit

class SpecialListViewController: UITableViewController {
    var headerView: SpecialPlusButtonView?
    var headerheightconstraint: NSLayoutConstraint?
    var currentheaderheight: CGFloat = 100
//    private var maxHeaderHeight: CGFloat = 100
//    private var minHeaderHeight: CGFloat = 50
//    private var previousScrollOffset: CGFloat = 0
    
// 헤더 grouped
//    init() {
//
//        super.init(style: .grouped)
////        super.viewDidLoad()
//        tableView.register(SpecialListViewCell.self, forCellReuseIdentifier: "SpecialCell")
//        tableView.separatorStyle = .none // 셀 선 제거
//        tableView.register(SpecialPlusButtonView.self, forHeaderFooterViewReuseIdentifier: "SpecialPlusButton")
//        navigationItem.title = "특이사항"
//        }
//        required init?(coder: NSCoder) {
//            super.init(coder: coder)
//        }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SpecialListViewCell.self, forCellReuseIdentifier: "SpecialCell")
        tableView.separatorStyle = .none // 셀 선 제거
        tableView.register(SpecialPlusButtonView.self, forHeaderFooterViewReuseIdentifier: "SpecialPlusButton")
        navigationItem.title = "특이사항"
        
//        updateHeaderView()
    }
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderView(scrollView)
    }
    
    private func updateHeaderView(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        if y > 0 {
            currentheaderheight = max(100 - y, 50)
        }
        else {
            currentheaderheight = 100
        }
        headerheightconstraint?.constant = currentheaderheight
//        let newHeight = 80
//        // 테이블 뷰에서 헤더 뷰 가져오기
//        if let headerView = tableView.headerView(forSection: 0) as? SpecialPlusButtonView {
//            print(headerView.frame.height)
//            headerView.snp.updateConstraints { make in
//                make.height.equalTo(newHeight)
//            }
//            headerView.setNeedsLayout()
//            headerView.layoutIfNeeded()
//        }
        
        // 테이블 뷰의 레이아웃 업데이트
//        tableView.beginUpdates()
//        tableView.endUpdates()
//        let y = -scrollView.contentOffset.y
//        var height = 90
//        if y > 90 {
//            height = 50
//        }
//        else {
//            height = 90
//        }
//        print(y)
//        headerView.snp.updateConstraints { make in
//            make.height.equalTo(height)
//        }
//
//        headerView.layoutIfNeeded()
//        tableView.beginUpdates()
//        tableView.endUpdates()
    }

////        let scrollOffset = tableView.contentOffset.y
////        let height = max(minHeaderHeight, maxHeaderHeight - scrollOffset)
////        if let header = tableView.headerView(forSection: 0) as? SpecialPlusButtonView {
////            header.updateHeight(height: height)
//
////        let offsetY = tableView.contentOffset.y
////
////        // 스크롤을 아래로 내릴 때만 헤더의 크기를 조정
////        if offsetY <= 0 {
////            let height = min(maxHeaderHeight, maxHeaderHeight - offsetY)
////            if let header = tableView.headerView(forSection: 0) as? SpecialPlusButtonView {
////                header.updateHeight(height: height)
////            }
////        }
//        let y = -scrollView.contentOffset.y
//        let height = min(max(y, 80), 220)
//
//        if let header = tableView.headerView(forSection: 0) as? SpecialPlusButtonView {
//            // 헤더 인스턴스의 높이 제약 조건을 업데이트합니다.
//            header.snp.updateConstraints { make in
//                make.height.equalTo(height)
//            }
//        }
//    }

    // MARK: - Table view data source

    // 셀 묶음 개수
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    // 셀 개수
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 10
    }
    // 셀 불러오기
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SpecialCell", for: indexPath)
        cell.selectionStyle = .none
        return cell
    }
    // 셀 높이
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        currentheaderheight
    }
    // 헤더 추가
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 0, let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SpecialPlusButton") as? SpecialPlusButtonView else {
            return UIView()
        }
        headerheightconstraint = headerView?.contentView.heightAnchor.constraint(equalToConstant: currentheaderheight)
        headerheightconstraint?.isActive = true
//        headerView = header
        header.contentView.backgroundColor = .white
        return header
    }
    // 헤더 높이
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        currentheaderheight
//        return maxHeaderHeight
    }
    
    

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

