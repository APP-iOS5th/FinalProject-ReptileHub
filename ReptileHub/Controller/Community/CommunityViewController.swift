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
    
    private let communityListView = CommunityListView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = communityListView
        
        communityListView.delegate = self
        communityListView.configureTableView(delegate: self, datasource: self)
        view.backgroundColor = .white
        title = "홈"
        
        setupSearchButton()
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(true)
        
        CommunityService.shared.fetchAllPostThumbnails(forCurrentUser: "R8FK52H2UebtfjNeODkNTEpsOgG3") { result in
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
        searchButton = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(actionSearchButton))
        
        self.navigationItem.rightBarButtonItem = searchButton
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
        return self.fetchTestData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! CommunityTableViewCell
        
        let fetchData = self.fetchTestData[indexPath.row]
        
        
        cell.configure(imageName: fetchData.thumbnailURL, title: fetchData.title, content: fetchData.previewContent, createAt: "\(fetchData.createdAt!)", commentCount: fetchData.commentCount, likeCount: fetchData.likeCount)
        
        UserService.shared.fetchUserProfile(uid: fetchData.userID) { result in
            
            switch result {
            case .success(let userData):
                print("현재 유저 정보 가져오기 성공 : \(userData)")
                cell.testUserProfile = userData
            case .failure(let error):
                print("현재 유저 정보 가져오기 실패 : \(error.localizedDescription)")
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailViewController = CommunityDetailViewController()
        
        var postDetailResponse: PostDetailResponse = PostDetailResponse(postID: "", userID: "", title: "", content: "", imageURLs: [], likeCount: 0, commentCount: 0, createdAt: Date(), isLiked: false)
        
        CommunityService.shared.fetchPostDetail(userID: UserService.shared.currentUserId, postID: self.fetchTestData[indexPath.row].postID) { result in
            switch result {
            case .success(let postDetail):
                print("상세 게시글 가져오기 성공")
                postDetailResponse = postDetail
                
                UserService.shared.fetchUserProfile(uid: self.fetchTestData[indexPath.row].userID) { result in
                    switch result {
                    case .success(let userData):
                        print("현재 유저 정보 가져오기 성공")
                        detailViewController.detailView.configureFetchData(profileImageName: userData.profileImageURL, title: postDetailResponse.title, name: userData.name, creatAt: "\(String(describing: postDetailResponse.createdAt))", imagesName: postDetailResponse.imageURLs, content: postDetailResponse.content, likeCount: postDetailResponse.likeCount, commentCount: postDetailResponse.commentCount, postID: postDetail.postID)
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


