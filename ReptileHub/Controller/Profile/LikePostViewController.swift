//
//  LikePostViewController.swift
//  Reptile_Hub_UI
//
//  Created by 육현서 on 8/8/24.
//

import UIKit

class LikePostViewController: UIViewController {
    
    private var fetchUserProfile: UserProfile?
    private let communityListView = CommunityListView()
    private let likePostView = LikePostView()
    var fetchBookmarks: [ThumbnailPostResponse] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.title = "북마크한 게시글"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.view = likePostView
        
        likePostView.configureLikePostTableView(delegate: self, datasource: self)
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(true)
    
        // MARK: - 북마크 불러오기
        UserService.shared.fetchBookmarkedPostThumbnails(forCurrentUser: UserService.shared.currentUserId) { result in
            switch result {
            case .success(let bookmarks):
                print("북마크 가져오기 성공")
                self.fetchBookmarks = bookmarks
                self.likePostView.likePostTableView.reloadData()
                print("가져온 북마크 개수(\(self.fetchBookmarks.count)개) : \(self.fetchBookmarks)")
            case .failure(let error):
                print("북마크 가져오기 실패 : \(error.localizedDescription)")
            }
        }
    } 
}


extension LikePostViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetchBookmarks.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "likeCell", for: indexPath) as! CommunityTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        let data = fetchBookmarks[indexPath.row]
        
        UserService.shared.fetchUserProfile(uid: data.userID) { result in
            switch result {
            case .success(let userData):
                cell.configure(imageName: data.thumbnailURL, title: data.title, content: data.previewContent, createAt: data.createdAt!.timefomatted, commentCount: data.commentCount, likeCount: data.likeCount, name: userData.name, postUserId: data.userID)
            case .failure(let error):
                print("현재 유저 정보 가져오기 실패 : \(error.localizedDescription)")
            }
        }
        return cell
    }
    
    // MARK: - 북마크 해제 기능
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
          if editingStyle == .delete {
              CommunityService.shared.toggleBookmarkPost(userID: UserService.shared.currentUserId, postID: fetchBookmarks[indexPath.row].postID) { result in
                  switch result {
                  case .success(let deleteBookmark):
                      print("북마크 해제 성공")
                      self.fetchBookmarks.remove(at: indexPath.row)
                      tableView.deleteRows(at: [indexPath], with: .fade)
                  case .failure(let error):
                      print("북마크 해제 실패: \(error.localizedDescription)")
                  }
              }
          }
      }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailViewController = CommunityDetailViewController()
        
        var postDetailResponse: PostDetailResponse = PostDetailResponse(postID: "", userID: "", title: "", content: "", imageURLs: [], likeCount: 0, commentCount: 0, createdAt: Date(), isLiked: false, isBookmarked: false)

        // MARK: - (북마크 한) 게시글 디테일 뷰 
        CommunityService.shared.fetchPostDetail(userID: UserService.shared.currentUserId, postID: self.fetchBookmarks[indexPath.row].postID) { result in
            switch result {
            case .success(let postDetail):
                print("상세 게시글 가져오기 성공")
                postDetailResponse = postDetail
               
                UserService.shared.fetchUserProfile(uid: self.fetchBookmarks[indexPath.row].userID) { result in
                    switch result {
                    case .success(let userData):
                        print("현재 유저 정보 가져오기 성공")
                        detailViewController.detailView.configureFetchData(postDetailData: postDetailResponse, likeCount:  self.fetchBookmarks[indexPath.row].likeCount, commentCount:  self.fetchBookmarks[indexPath.row].commentCount, profileImageName: userData.profileImageURL, name: userData.name)
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
