//
//  CommunityDetailViewController.swift
//  ReptileHub
//
//  Created by 조성빈 on 8/12/24.
//

import UIKit
import SnapKit

class CommunityDetailViewController: UIViewController {

    let detailView = CommunityDetailView()
    
    var fetchComments: [CommentResponse] = []
    
    var tableViewHeight: CGFloat = 0
    
    private var menuButton: UIBarButtonItem = UIBarButtonItem()
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        self.title = "커뮤니티"
        
        setupMenuButton()
        setupDetailView()
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(true)
        
        tableViewHeight = 0
        
        CommunityService.shared.fetchComments(forPost: detailView.postID) { result in
            switch result {
            case .success(let comments):
                print("해당 게시글의 모든 댓글 가져오기 성공")
                self.fetchComments = comments
                
                var height: CGFloat = 50
                
                for comment in comments {
                    height = height + self.getLabelHeight(tableView: self.detailView.commentTableView, text: comment.content) + 50
                }
                self.detailView.updateCommentTableViewHeight(height: height)
                
                self.detailView.commentTableView.reloadData()
                print("가져온 댓글 개수(\(self.fetchComments.count)개) : \(self.fetchComments)")
            case .failure(let error):
                print("해당 게시글의 모든 댓글 가져오기 실패 : \(error.localizedDescription)")
            }
        }
    }
    

    
    //MARK: - menu 버튼
    private func setupMenuButton() {
        let ellipsisImage = UIImage(systemName: "ellipsis")
        
        // UIButton을 생성하여 회전
        let button = UIButton(type: .system)
        button.setImage(ellipsisImage, for: .normal)
        button.tintColor = .black
        button.transform = CGAffineTransform(rotationAngle: .pi / 2) // 90도 회전
        
        button.addTarget(self, action: #selector(actionMenuButton), for: .touchUpInside)
        
        menuButton = UIBarButtonItem(customView: button)
        
        self.navigationItem.rightBarButtonItem = menuButton
    }
    
    //MARK: - 커뮤니티 디테일 뷰 setup
    private func setupDetailView() {
        self.view = detailView
        detailView.backgroundColor = .white
        detailView.configureTableView(scrollViewDelegate: self, tableViewDelegate: self, tableViewDatasource: self, textViewDelegate: self)
    }
    
    @objc
    private func actionMenuButton() {
        print("메뉴 버튼 클릭.")
    }
    
    func getLabelHeight(tableView: UITableView, text: String) -> CGFloat {
            let label = UILabel(
                frame: .init(
                    x: .zero,
                    y: .zero,
                    width: tableView.frame.width - 75,
                    height: .greatestFiniteMagnitude
                )
            )
            label.text = text
            label.numberOfLines = 0
            label.font = .systemFont(ofSize: 13)
            label.sizeToFit()
            let labelHeight = label.frame.height
            return labelHeight
        }

    
}


extension CommunityDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        detailView.imageScrollCount(scrollView: scrollView)
    }
}

extension CommunityDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("출력 전 개수 : \(self.fetchComments.count)")
        return self.fetchComments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentTableViewCell
        
        let commentData = self.fetchComments[indexPath.row]
        
        UserService.shared.fetchUserProfile(uid: self.fetchComments[indexPath.row].userID) { result in
            switch result {
            case .success(let userData):
                print("CommunityDetailVC 유저 정보 가져오기 성공")
                cell.configureCell(profileURL: userData.profileImageURL, name: userData.name, content: commentData.content, createAt: "\(commentData.createdAt!)")
            case .failure(let error):
                print("CommunityDetailVC 유저 정보 가져오기 실패 : \(error.localizedDescription)")
            }
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("댓글 셀 클릭")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let labelHeight = getLabelHeight(tableView: tableView, text: self.fetchComments[indexPath.row].content)

        return labelHeight + 50
    }
    
    
}

extension CommunityDetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        detailView.textViewChange(textView: textView)
    }
}
