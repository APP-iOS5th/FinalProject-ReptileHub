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
            UIAction(title: "게시글 수정하기", image: UIImage(systemName: "square.and.pencil"), handler: { _ in
                self.editButtonAction()
            }),
            UIAction(title: "게시글 삭제하기", image: UIImage(systemName: "trash"), attributes: .destructive, handler: { _ in
                self.deleteButtonAction()
            })
        ]
        
        otherMenu = [
            UIAction(title: "작성자 차단하기", image: UIImage(systemName: "hand.raised"), handler: { _ in
                self.blockButtonAction()
            }),
            UIAction(title: "신고하기", image: UIImage(systemName: "exclamationmark.bubble"), attributes: .destructive, handler: { _ in
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
        print("디테일 뷰에서의 수정하기 클릭.")
        let addPostViewController = AddPostViewController(postId: detailView.postID, editMode: true)
        
        addPostViewController.delegate = self
        
        addPostViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(addPostViewController, animated: true)
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
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }))
        present(alert, animated: true, completion: nil)
    }

    private func blockButtonAction() {
        print("block")
        let alert = UIAlertController(title: "알림", message: "해당 게시글 작성자를 차단하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "차단하기", style: .destructive, handler: { _ in
            
            UserService.shared.blockUser(currentUserID: UserService.shared.currentUserId, blockUserID: self.detailView.postUserId) { error in
                if let error = error {
                    print("차단 실패 : \(error.localizedDescription)")
                } else {
                    print("차단 성공, 뒤로 가기.")
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func reportButtonAction() {
        let alert = UIAlertController(title: "신고", message: "해당 게시글의 작성자를 신고하시겠습니까?", preferredStyle: .alert)
        
        // 텍스트 필드 추가
        alert.addTextField { textField in
            textField.placeholder = "신고 사유를 입력하세요"
        }
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "신고", style: .destructive, handler: { _ in
            // 텍스트 필드에서 입력된 값 가져오기
            let reportReason = alert.textFields?.first?.text ?? "신고되었음"
            
            UserService.shared.reportPost(postID: self.detailView.postID, reportedUserID: self.detailView.postUserId, currentUserID: UserService.shared.currentUserId, content: reportReason) { error in
                if let error = error {
                    print("게시글 신고 에러 : \(error.localizedDescription)")
                } else {
                    print("게시글 신고 완료")
                    
                    // 신고 완료 메시지 알림 띄우기
                    let successAlert = UIAlertController(title: "신고 완료", message: "신고가 성공적으로 처리되었습니다.", preferredStyle: .alert)
                    successAlert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                    self.present(successAlert, animated: true, completion: nil)
                }
            }
        }))
        
        present(alert, animated: true, completion: nil)
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
    func onTapProfileImage(postUserId: String) {

        UserService.shared.fetchUserProfile(uid: postUserId) { result in
            switch result {
            case .success(let userData):
                // 해당유저가 탈퇴된 계정인지 확인
//                if !userData.isValid {
                let profileVC = ProfileViewController()
                    profileVC.profileView.setProfileData(userData: userData)
                profileVC.currentUserProfile = userData
                profileVC.isMyProfile = false
                self.navigationController?.pushViewController(profileVC, animated: true)
//                } else {
//                    // 탈퇴한 계정이라는 alert 필요
//                }
            case .failure(let error):
                print("클릭한 유저의 프로필 가져오기 실패 : \(error.localizedDescription)")
            }
        }

    }
    
    func createCommentAction(postId: String, commentText: String) {
        CommunityService.shared.addComment(postID: postId, userID: UserService.shared.currentUserId, content: commentText) { result in
            switch result {
            case .success(let latestComments):
                self.detailView.commentTextView.text = ""
                self.detailView.sendButton.isEnabled = false
                self.detailView.sendButton.tintColor = UIColor.lightGray
                self.fetchComments = latestComments
                
                var height: CGFloat = 50
                
                for comment in self.fetchComments {
                    height = height + self.getLabelHeight(tableView: self.detailView.commentTableView, text: comment.content) + 50
                }
                self.detailView.updateCommentTableViewHeight(height: height)
                
                self.detailView.commentTableView.reloadData()
                
                // 디테일 뷰의 댓글 카운트 1 증가
                self.detailView.addCommentCount()
            case .failure(let error):
                print("영등포 차은우 : \(error.localizedDescription)")
            }
        }
    }
    
}

extension CommunityDetailViewController: CommentTableViewCellDelegate {
    func reportCommentAction(cell: CommentTableViewCell) {
        print("댓글 신고!")
        guard let indexPath = self.detailView.commentTableView.indexPath(for: cell) else { return }
        let alert = UIAlertController(title: "신고", message: "해당 댓글의 작성자를 신고하시겠습니까?", preferredStyle: .alert)
        
        // 텍스트 필드 추가
        alert.addTextField { textField in
            textField.placeholder = "신고 사유를 입력하세요"
        }
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "신고", style: .destructive, handler: { _ in
            // 텍스트 필드에서 입력된 값 가져오기
            let reportReason = alert.textFields?.first?.text ?? "신고되었음"
            
            UserService.shared.reportComment(postID: self.detailView.postID, commentID: self.fetchComments[indexPath.row].commentID, reportedUserID: self.fetchComments[indexPath.row].userID, currentUserID: UserService.shared.currentUserId, content: reportReason) { error in
                if let error = error {
                    print("댓글 신고 에러")
                } else {
                    print("댓글 신고 성고")
                    // 신고 완료 메시지 알림 띄우기
                    let successAlert = UIAlertController(title: "신고 완료", message: "신고가 성공적으로 처리되었습니다.", preferredStyle: .alert)
                    successAlert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                    self.present(successAlert, animated: true, completion: nil)
                }
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func onTapCommentProfile(cell: CommentTableViewCell) {
        guard let indexPath = self.detailView.commentTableView.indexPath(for: cell) else { return }
        
        UserService.shared.fetchUserProfile(uid: self.fetchComments[indexPath.row].userID) { result in
            switch result {
            case .success(let userData):
                // 해당 유저가 탈퇴계정인지 확인
                //                if userData.isValid {
                let profileVC = ProfileViewController()
                profileVC.profileView.setProfileData(userData: userData)
                profileVC.currentUserProfile = userData
                profileVC.isMyProfile = false
                self.navigationController?.pushViewController(profileVC, animated: true)
                //                } else {
                //
                //                }
            case .failure(let error):
                print("끄아아아아아아앙!!: \(error.localizedDescription)")
            }
        }
    }

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
                    self.detailView.commentTableView.deleteRows(at: [indexPath], with: .none)
                    
                    var height: CGFloat = 50

                    for comment in self.fetchComments {
                        height = height + self.getLabelHeight(tableView: self.detailView.commentTableView, text: comment.content) + 50
                    }
                    self.detailView.updateCommentTableViewHeight(height: height)
                    
                    self.detailView.subtractCommentCount()
                }
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func blockCommentAction(cell: CommentTableViewCell) {
        let alert = UIAlertController(title: "알림", message: "해당 유저를 차단하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "차단하기", style: .destructive, handler: { _ in
            // 선택한 셀의 indexPath
            guard let indexPath = self.detailView.commentTableView.indexPath(for: cell) else { return }
            
            UserService.shared.blockUser(currentUserID: UserService.shared.currentUserId, blockUserID: self.fetchComments[indexPath.row].userID) { error in
                if let error = error {
                    print("차단 실패 : \(error.localizedDescription)")
                } else {
                    print("댓글 작성자 차단 성공")
                }
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
}

extension CommunityDetailViewController: AddPostViewControllerDelegate {
    func dismissAddPost(detailPostData: PostDetailResponse) {
                UserService.shared.fetchUserProfile(uid: self.detailView.postUserId) { result in
                    switch result {
                    case .success(let userData):
                        self.detailView.configureFetchData(postDetailData: detailPostData, likeCount: Int(self.detailView.likeCount.text ?? "0") ?? 0, commentCount: Int(self.detailView.commentCount.text ?? "0") ?? 0, profileImageName: userData.profileImageURL, name: userData.name)
                        
                    case .failure(let error):
                        print("에러에러에러")
                    }
                }
        
    }
}
