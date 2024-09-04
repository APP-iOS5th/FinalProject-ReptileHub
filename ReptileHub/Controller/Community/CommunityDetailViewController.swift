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
    
    private var menuBarButton: UIBarButtonItem = UIBarButtonItem()
    private var menuButton: UIButton = UIButton()
    private var myMenu: [UIAction] = []
    private var otherMenu: [UIAction] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        self.title = "커뮤니티"
        
        detailView.delegate = self
        
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
        menuButton = UIButton(type: .system)
        menuButton.setImage(ellipsisImage, for: .normal)
        menuButton.tintColor = .black
        menuButton.transform = CGAffineTransform(rotationAngle: .pi / 2) // 90도 회전
        
        // 메뉴 버튼을 눌렀을 때 메뉴가 보이도록 설정
        menuButton.showsMenuAsPrimaryAction = true
        
        let isMine: Bool = detailView.postUserId == UserService.shared.currentUserId
        
        myMenu = [
            UIAction(title: "수정하기", image: UIImage(systemName: "pencil"), handler: { _ in
                self.editButtonAction()
            }),
            UIAction(title: "삭제하기", image: UIImage(systemName: "trash"), attributes: .destructive, handler: { _ in
                self.deleteButtonAction()
            })
        ]
        
        otherMenu = [
            UIAction(title: "차단하기", image: UIImage(systemName: "hand.raised"), handler: { _ in
                self.blockButtonAction()
            }),
            UIAction(title: "신고하기", image: UIImage(systemName: "exclamationmark.triangle"), attributes: .destructive, handler: { _ in
                self.reportButtonAction()
            })
        ]
        
        menuButton.menu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: isMine ? myMenu : otherMenu)
        
        
        // UIBarButtonItem에 커스텀 UIButton을 설정
        menuBarButton = UIBarButtonItem(customView: menuButton)
        
        // navigationItem에 설정
        self.navigationItem.rightBarButtonItem = menuBarButton
    }
    
    private func editButtonAction() {
        print("edit")
    }
    
    private func deleteButtonAction() {
        print("delete")
        let alert = UIAlertController(title: "알림", message: "게시글을 삭제하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
            CommunityService.shared.deletePost(postID: self.detailView.postID, userID: self.detailView.postUserId) { error in
                if let error = error {
                    print("게시글 삭제 중 오류 발생: \(error.localizedDescription)")
                } else {
                    print("게시글 삭제 성공")
                    self.dismiss(animated: true)
                }
            }
        }))
        present(alert, animated: true, completion: nil)
    }

    private func blockButtonAction() {
        print("block")
    }
    
    private func reportButtonAction() {
        print("report")
    }
    
    //MARK: - 커뮤니티 디테일 뷰 setup
    private func setupDetailView() {
        self.view = detailView
        detailView.backgroundColor = .white
        detailView.configureTableView(scrollViewDelegate: self, tableViewDelegate: self, tableViewDatasource: self, textViewDelegate: self)
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
        
        cell.delegate = self
        
        let commentData = self.fetchComments[indexPath.row]
        
        guard let createAt = commentData.createdAt?.timefomatted else { return cell }
        
        UserService.shared.fetchUserProfile(uid: commentData.userID) { result in
            switch result {
            case .success(let userData):
                print("CommunityDetailVC 유저 정보 가져오기 성공")
                cell.configureCell(profileURL: userData.profileImageURL, name: userData.name, content: commentData.content, createAt: createAt, commentUserId: commentData.userID)
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

extension CommunityDetailViewController: CommunityDetailViewDelegate {
    func createCommentAction(postId: String, commentText: String) {
        CommunityService.shared.addComment(postID: postId, userID: UserService.shared.currentUserId, content: commentText) { error in
            if let error = error {
                print("댓글 작성 에러 : \(error.localizedDescription)")
            } else {
                print("댓글 작성 성공!")
                CommunityService.shared.fetchComments(forPost: postId) { result in
                    switch result {
                    case .success(let commentsData):
                        self.fetchComments = commentsData
                        
                        var height: CGFloat = 50

                        for comment in self.fetchComments {
                            height = height + self.getLabelHeight(tableView: self.detailView.commentTableView, text: comment.content) + 50
                        }
                        self.detailView.updateCommentTableViewHeight(height: height)
                        
                        self.detailView.commentTableView.reloadData()
                        
                        // 디테일 뷰의 댓글 카운트 1 증가
                        self.detailView.addCommentCount()
                    case .failure(let error):
                        print("추가된 댓글 포함하여 댓글 가져오기 실패 : \(error.localizedDescription)")
                    }
                }
                
            }
        }
    }
    
}

extension CommunityDetailViewController: CommentTableViewCellDelegate {
    func deleteCommentAction(cell: CommentTableViewCell) {
        let alert = UIAlertController(title: "알림", message: "댓글을 삭제하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
            // 선택한 셀의 indexPath
            guard let indexPath = self.detailView.commentTableView.indexPath(for: cell) else { return }
            
            CommunityService.shared.deleteComment(postID: self.detailView.postID, commentID: self.fetchComments[indexPath.row].commentID) { error in
                if let error = error {
                    print("댓글 삭제 중 오류 발생: \(error.localizedDescription)")
                } else {
                    print("댓글 삭제 성공")
                    self.fetchComments.remove(at: indexPath.row)
                    self.detailView.commentTableView.deleteRows(at: [indexPath], with: .automatic)
                    self.detailView.subtractCommentCount()
                }
            }
        }))
        present(alert, animated: true, completion: nil)
    }
}
