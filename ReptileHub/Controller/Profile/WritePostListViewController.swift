//
//  WritePostListViewController.swift
//  Reptile_Hub_UI
//
//  Created by 육현서 on 8/8/24.
//

import UIKit

class WritePostListViewController: UIViewController {
    
    
    private var fetchUserProfile: UserProfile?
    private let communityListView = CommunityListView()
    
    private let writePostListView = WritePostListView()
    var fetchPosts: [ThumbnailPostResponse] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.title = "내가 쓴 게시글"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.view = writePostListView
        
        writePostListView.configureWritePostTableView(delegate: self, datasource: self)
        
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(true)
      
        UserService.shared.fetchUserPostsThumbnails(userID: UserService.shared.currentUserId) { result in
            switch result {
            case .success(let userPosts):
                print("해당 게시글의 모든 댓글 가져오기 성공")
                self.fetchPosts = userPosts
                self.writePostListView.WritePostTableView.reloadData()
                print("가져온 북마크 개수(\(self.fetchPosts.count)개) : \(self.fetchPosts)")
            case .failure(let error):
                print("해당 게시글의 모든 북마크 가져오기 실패 : \(error.localizedDescription)")
            }
        }
    }
}

extension WritePostListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetchPosts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        85
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CommunityTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.delegate = self
        
        let data = fetchPosts[indexPath.row]
//        cell.configure(imageName: data.thumbnailURL, title: data.title, content: data.previewContent, createAt: data.createdAt!.timefomatted, commentCount: data.commentCount, likeCount: data.likeCount)
        
        UserService.shared.fetchUserProfile(uid: UserService.shared.currentUserId) { result in
            switch result {
            case .success(let userData):
                cell.configure(imageName: data.thumbnailURL, title: data.title, content: data.previewContent, createAt: data.createdAt!.timefomatted, commentCount: data.commentCount, likeCount: data.likeCount, name: userData.name, postUserId: data.userID, isInProfile: true)
            case .failure(let error):
                print("현재 유저 정보 가져오기 실패 : \(error.localizedDescription)")
                
            }
        }
        
//        let menuItems = [
//            UIAction(title: "삭제하기", image: UIImage(systemName: "trash"),attributes: .destructive,handler: { _ in}),
//        ]
//        // UIMenu title 설정
//        let menu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: menuItems)
//        // 셀에 메뉴 설정
//        cell.configure(with: menu)
        
        return cell
    }
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailViewController = CommunityDetailViewController()
        
        var postDetailResponse: PostDetailResponse = PostDetailResponse(postID: "", userID: "", title: "", content: "", imageURLs: [], likeCount: 0, commentCount: 0, createdAt: Date(), isLiked: false, isBookmarked: false)
        
        CommunityService.shared.fetchPostDetail(userID: UserService.shared.currentUserId, postID: self.fetchPosts[indexPath.row].postID) { result in
            switch result {
            case .success(let postDetail):
                print("상세 게시글 가져오기 성공")
                postDetailResponse = postDetail
                
                UserService.shared.fetchUserProfile(uid: self.fetchPosts[indexPath.row].userID) { result in
                    switch result {
                    case .success(let userData):
                        print("현재 유저 정보 가져오기 성공")
                        detailViewController.detailView.configureFetchData(postDetailData: postDetailResponse, likeCount:  self.fetchPosts[indexPath.row].likeCount, commentCount:  self.fetchPosts[indexPath.row].commentCount, profileImageName: userData.profileImageURL, name: userData.name)
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

extension WritePostListViewController: CommunityTableViewCellDelegate {
    func blockAlert(cell: CommunityTableViewCell) {
        print("")
    }
    
    
    func deleteAlert(cell: CommunityTableViewCell) {
        let alert = UIAlertController(title: "알림", message: "게시글을 삭제하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
            // 선택한 셀의 indexPath
            guard let indexPath = self.writePostListView.WritePostTableView.indexPath(for: cell) else { return }
            
            CommunityService.shared.deletePost(postID: self.fetchPosts[indexPath.row].postID, userID: self.fetchPosts[indexPath.row].userID) { error in
                if let error = error {
                    print("게시글 삭제 중 오류 발생: \(error.localizedDescription)")
                } else {
                    print("게시글 삭제 성공")
                }
            }
            
            self.fetchPosts.remove(at: indexPath.row)
            
            // 선택한 셀을 테이블 뷰에서 삭제
            self.writePostListView.WritePostTableView.deleteRows(at: [indexPath], with: .automatic)
        }))
        present(alert, animated: true, completion: nil)
    }

}
