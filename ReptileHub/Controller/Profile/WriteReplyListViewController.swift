//
//  WriteReplyListViewController.swift
//  Reptile_Hub_UI
//
//  Created by 육현서 on 8/13/24.
//

import UIKit

class WriteReplyListViewController: UIViewController {
    
    var fetchUserData: UserProfile?
    private let communityListView = CommunityListView()
    let writeReplyView = WriteReplyListView()
    let detailView = CommunityDetailView()
    var fetchComments: [CommentResponse] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.title = "내가 작성한 댓글"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.view = writeReplyView
        
        writeReplyView.configureReplyTableView(delegate: self, datasource: self)
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(true)
        guard let fetchUid = fetchUserData?.uid else { return }
        UserService.shared.fetchAllUserComments(userID: fetchUid) { result in
            switch result {
            case .success(let comments):
                print("댓글 가져오기 성공")
                self.fetchComments = comments
                self.writeReplyView.replyListTableView.reloadData()
                print("가져온 댓글 개수(\(self.fetchComments.count)개) : \(self.fetchComments)")
            case .failure(let error):
                print("댓글 가져오기 실패 : \(error.localizedDescription)")
            }
        }
    }
}


extension WriteReplyListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetchComments.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        87
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "replyCell", for: indexPath) as! WriteReplyListTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.delegate = self
        
        CommunityService.shared.fetchPostDetail(userID: UserService.shared.currentUserId, postID: fetchComments[indexPath.row].postID) { result in
            switch result {
            case .success(let fetchCommentPost):
                cell.setCommentData(commentData: self.fetchComments[indexPath.row], postData: fetchCommentPost)
            case .failure(let error):
                print("\(error.localizedDescription)")
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailViewController = CommunityDetailViewController()
        
        var postDetailResponse: PostDetailResponse = PostDetailResponse(postID: "", userID: "", title: "", content: "", imageURLs: [], likeCount: 0, commentCount: 0, createdAt: Date(), isLiked: false, isBookmarked: false)
        
        // MARK: - (댓글 단) 게시글 디테일 뷰
        CommunityService.shared.fetchPostDetail(userID: UserService.shared.currentUserId, postID: self.fetchComments[indexPath.row].postID) { result in
            switch result {
            case .success(let postDetail):
                print("상세 게시글 가져오기 성공")
                postDetailResponse = postDetail
                
                UserService.shared.fetchUserProfile(uid: postDetailResponse.userID) { result in
                    switch result {
                    case .success(let userData):
                        print("현재 유저 정보 가져오기 성공")
                        detailViewController.detailView.configureFetchData(postDetailData: postDetailResponse, likeCount: postDetailResponse.likeCount,  commentCount: postDetailResponse.commentCount, profileImageName: userData.profileImageURL, name: userData.name)
                        detailViewController.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(detailViewController, animated: true)
                    case .failure(let error):
                        print("현재 유저 정보 가져오기 실패 : \(error.localizedDescription)")
                    }
                }
                
            case .failure(let error):
                print("상세 게시글 가져오기 실패 : \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - 댓글 삭제 기능
extension WriteReplyListViewController: WriteReplyListTableViewCellDelegate {
    func deleteComment(cell: WriteReplyListTableViewCell) {
        guard let indexPath = self.writeReplyView.replyListTableView.indexPath(for: cell) else { return }
        CommunityService.shared.deleteComment(postID: self.fetchComments[indexPath.row].postID, commentID: self.fetchComments[indexPath.row].commentID) { error in
            if let error = error {
                print("댓글 삭제 실패: \(error.localizedDescription)")
            } else {
                print("댓글 삭제 성공")
                print(self.fetchComments[indexPath.row])
                self.fetchComments.remove(at: indexPath.row)
                self.writeReplyView.replyListTableView.deleteRows(at: [indexPath], with: .none)
            }
        }
    }
}
