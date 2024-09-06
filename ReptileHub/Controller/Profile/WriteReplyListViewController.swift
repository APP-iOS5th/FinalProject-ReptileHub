//
//  WriteReplyListViewController.swift
//  Reptile_Hub_UI
//
//  Created by 육현서 on 8/13/24.
//

import UIKit

class WriteReplyListViewController: UIViewController {
    
    private var fetchUserProfile: UserProfile?
    private let communityListView = CommunityListView()
    
    private let writeReplyView = WriteReplyListView()
    
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
        
        UserService.shared.fetchAllUserComments(userID: UserService.shared.currentUserId) { result in
            switch result {
            case .success(let comments):
                print("해당 게시글의 모든 댓글 가져오기 성공")
                self.fetchComments = comments
                self.writeReplyView.replyListTableView.reloadData()
                print("가져온 댓글 개수(\(self.fetchComments.count)개) : \(self.fetchComments)")
            case .failure(let error):
                print("해당 게시글의 모든 댓글 가져오기 실패 : \(error.localizedDescription)")
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

        CommunityService.shared.fetchPostDetail(userID: UserService.shared.currentUserId, postID: self.fetchComments[indexPath.row].postID) { result in
            switch result {
            case .success(let postDetail):
                print("상세 게시글 가져오기 성공")
                postDetailResponse = postDetail

                UserService.shared.fetchUserProfile(uid: self.fetchComments[indexPath.row].userID) { result in
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
