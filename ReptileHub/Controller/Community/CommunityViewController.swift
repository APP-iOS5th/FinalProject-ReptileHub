//
//  CommunityViewController.swift
//  ReptileHub
//
//  Created by 조성빈 on 8/5/24.
//

import UIKit
import SnapKit


class CommunityViewController: UIViewController {
    
    private var fetchTestData: [ThumbnailPostResponse] = []
    private var fetchUserProfile: UserProfile?
    
    private var searchButton: UIBarButtonItem = UIBarButtonItem()
    
    private var filteredPosts: [ThumbnailPostResponse] = []
    
    var isFiltering: Bool {
        let searchController = self.navigationItem.searchController
        let isActive = searchController?.isActive ?? false
        let isSearchBarHasText = searchController?.searchBar.text?.isEmpty == false
        
        return isActive && isSearchBarHasText
    }
    
    private let communityListView = CommunityListView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view = communityListView
        
        communityListView.delegate = self
        communityListView.configureTableView(delegate: self, datasource: self)
        view.backgroundColor = .white
        title = "커뮤니티"
        
        setupSearchButton()
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(true)
        
        CommunityService.shared.fetchAllPostThumbnails(forCurrentUser: UserService.shared.currentUserId) { result in
            switch result {
            case .success(let thumnails):
                print("차단유저 제외 모든 post 불러오기 성공")
                self.fetchTestData = thumnails
                self.communityListView.communityTableView.reloadData()
            case .failure(let error):
                print("모든 post 불러오기 실패 : \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: - rightBarButtonItem 적용
    private func setupSearchButton() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "검색어를 입력하세요"
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchResultsUpdater = self
    }
    
    @objc
    private func actionSearchButton() {
        print("돋보기 버튼 클릭.")
    }
    
    
    
    
}

extension CommunityViewController: CommunityListViewDelegate {
    func didTapAddPostButton() {
        let addPostViewController = AddPostViewController()
        addPostViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(addPostViewController, animated: true)
    }
}


extension CommunityViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isFiltering ? self.filteredPosts.count : self.fetchTestData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! CommunityTableViewCell
        
        cell.delegate = self
        
        let fetchData = self.fetchTestData[indexPath.row]
        
        UserService.shared.fetchUserProfile(uid: fetchData.userID) { result in
            
            switch result {
            case .success(let userData):
//                print("Community VC현재 유저 정보 가져오기 성공")
                
                if self.isFiltering {
                    let filteredData = self.filteredPosts[indexPath.row]
                    cell.configure(imageName: filteredData.thumbnailURL, title: filteredData.title, content: filteredData.previewContent, createAt: filteredData.createdAt!.timefomatted, commentCount: filteredData.commentCount, likeCount: filteredData.likeCount, name: userData.name, postUserId:  filteredData.userID, isInProfile: false)
                } else {
                    cell.configure(imageName: fetchData.thumbnailURL, title: fetchData.title, content: fetchData.previewContent, createAt: fetchData.createdAt!.timefomatted, commentCount: fetchData.commentCount, likeCount: fetchData.likeCount, name: userData.name, postUserId: fetchData.userID, isInProfile: false)
                }
                
            case .failure(let error):
                print("현재 유저 정보 가져오기 실패 : \(error.localizedDescription)")
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailViewController = CommunityDetailViewController()
        
        CommunityService.shared.fetchPostDetail(userID: UserService.shared.currentUserId, postID: self.fetchTestData[indexPath.row].postID) { result in
            switch result {
            case .success(let postDetail):
                print("상세 게시글 가져오기 성공")
            
                UserService.shared.fetchUserProfile(uid: self.fetchTestData[indexPath.row].userID) { result in
                    switch result {
                    case .success(let userData):
                        print("현재 유저 정보 가져오기 성공")
                        
                        detailViewController.detailView.configureFetchData(postDetailData: postDetail, likeCount: self.fetchTestData[indexPath.row].likeCount, commentCount: self.fetchTestData[indexPath.row].commentCount, profileImageName: userData.profileImageURL, name: userData.name)
                        detailViewController.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(detailViewController, animated: true)
                    case .failure(let error):
                        print("현재 유저 정보 가져오기 실패 : \(error.localizedDescription)")
                    }
                }
                
            case .failure(let error):
                print("상세 게시글 가져오기 실패 : \(error.localizedDescription)")
                print("해당 게시글은 삭제된 게시글임. 리로드.")
                CommunityService.shared.fetchAllPostThumbnails(forCurrentUser: UserService.shared.currentUserId) { result in
                    switch result {
                    case .success(let newPostList):
                        self.fetchTestData = newPostList
                        self.communityListView.communityTableView.reloadData()
                    case .failure(let error):
                        print("게시글 다시 불러오기 에러 : \(error.localizedDescription)")
                    }
                }

            }
        }

    }
}

extension CommunityViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text?.lowercased() else { return }
        self.filteredPosts = self.fetchTestData.filter { $0.title.lowercased().contains(text)}
        
        self.communityListView.communityTableView.reloadData()
    }
}


extension CommunityViewController: CommunityTableViewCellDelegate {
    
    func deleteAlert(cell: CommunityTableViewCell) {
        let alert = UIAlertController(title: "알림", message: "게시글을 삭제하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
            // 선택한 셀의 indexPath
            guard let indexPath = self.communityListView.communityTableView.indexPath(for: cell) else { return }
            
            CommunityService.shared.deletePost(postID: self.fetchTestData[indexPath.row].postID, userID: self.fetchTestData[indexPath.row].userID) { error in
                if let error = error {
                    print("게시글 삭제 중 오류 발생: \(error.localizedDescription)")
                } else {
                    print("게시글 삭제 성공")
                }
            }
            
            self.fetchTestData.remove(at: indexPath.row)
            
            // 선택한 셀을 테이블 뷰에서 삭제
            self.communityListView.communityTableView.deleteRows(at: [indexPath], with: .automatic)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func blockAlert(cell: CommunityTableViewCell) {
        let alert = UIAlertController(title: "알림", message: "해당 유저를 차단하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "차단하기", style: .destructive, handler: { _ in
            // 선택한 셀의 indexPath
            guard let indexPath = self.communityListView.communityTableView.indexPath(for: cell) else { return }
            
            UserService.shared.blockUser(currentUserID: UserService.shared.currentUserId, blockUserID: self.fetchTestData[indexPath.row].userID) { error in
                if let error = error {
                    print("차단 실패 : \(error.localizedDescription)")
                } else {
                    print("차단 성공, 게시글 리로드")
                    CommunityService.shared.fetchAllPostThumbnails(forCurrentUser: UserService.shared.currentUserId) { result in
                        switch result {
                        case .success(let afterBlockPosts):
                            self.fetchTestData = afterBlockPosts
                            self.communityListView.communityTableView.reloadData()
                        case .failure(let error):
                            print("차단 후 게시글 리로드 실패 : \(error.localizedDescription)")
                        }
                    }
                }
            }
        }))
        present(alert, animated: true, completion: nil)
    }

}
