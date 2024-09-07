//
//  BlockUserViewController.swift
//  Reptile_Hub_UI
//
//  Created by 육현서 on 8/8/24.
//

import UIKit

class BlockUserViewController: UIViewController {
    
    private let blockUserView = BlockUserView()
    private var blockUsers : [BlockUserProfile] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.title = "내가 차단한 사용자"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.view = blockUserView
        blockUserView.configureBlockUserTableView(delegate: self, datasource: self)
    }
    
    // MARK: - 차단 유저 불러오기
    override func viewIsAppearing(_ animated: Bool) {
        UserService.shared.fetchBlockUsers(currentUserID: UserService.shared.currentUserId) { result in
            switch result {
            case .success(let blockUserData):
                self.blockUsers = blockUserData
                self.blockUserView.blockUserTableView.reloadData()
                print("불러오기 성공: \(self.blockUsers)")
            case .failure(let error):
                print("불러오기 실패: \(error.localizedDescription)")
            }
        }
    }
}

extension BlockUserViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blockUsers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! BlockUserTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.setBlockUserData(blockUserData: blockUsers[indexPath.row])
        cell.delegate = self
        return cell
    }
}

// MARK: - 차단 해제 기능
extension BlockUserViewController: BlockUserTableViewCellDelegate {
    func deleteBlockAction(cell: BlockUserTableViewCell) {
        guard let indexPath = self.blockUserView.blockUserTableView.indexPath(for: cell) else {return}
        UserService.shared.unblockUser(currentUserID: UserService.shared.currentUserId, unBlockUserID: self.blockUsers[indexPath.row].uid) { error in
            if let error = error {
                print("차단해제 실패: \(error.localizedDescription)")
            } else {
                print("차단해제 완료")
                self.blockUsers.remove(at: indexPath.row)
                self.blockUserView.blockUserTableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
}
