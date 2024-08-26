//
//  PostDetailViewController.swift
//  ReptileHub
//
//  Created by 임재현 on 8/23/24.
//

import UIKit
import PhotosUI

class PostDetailViewController: UIViewController {

    var postDetail: PostDetailResponse?

    
    override func viewWillAppear(_ animated: Bool) {
        setupUI()
        fetchPostDetail()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
//        setupUI()
//        fetchPostDetail()
    }

    private func setupUI() {
        // Edit 버튼 생성
        let editButton = UIButton(type: .system)
        editButton.setTitle("수정하기", for: .normal)
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(editButton)
        
        // Edit 버튼 제약 조건 설정
        NSLayoutConstraint.activate([
            editButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            editButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            editButton.widthAnchor.constraint(equalToConstant: 100),
            editButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func fetchPostDetail() {
        let userID = "XYmrUBcFhjdYZSM8TFihX0QNN7O2"
        let postID = "0E9C6F79-6C8F-4E61-A2C5-AE6A1EEE9560"
        CommunityService.shared.fetchPostDetail(userID: userID, postID: postID) { result in
            switch result {
            case .success(let postDetail):
                self.postDetail = postDetail
                self.updateUI(with: postDetail)
            case .failure(let error):
                print("Failed to fetch post detail: \(error.localizedDescription)")
            }
        }
    }

    private func updateUI(with postDetail: PostDetailResponse) {
        print("불러온 데이터 -\(postDetail)")
    }

    @objc private func editButtonTapped() {
        guard let postDetail = postDetail else { return }

        downloadImages(from: postDetail.imageURLs) { images in
            DispatchQueue.main.async {
                let editVC = PostEditViewController()
                editVC.postDetail = postDetail
                editVC.images = images.compactMap { $0 } // 이미지 배열을 설정
                editVC.originalImageURLs = postDetail.imageURLs // 원래 URL 배열을 설정
                editVC.modalPresentationStyle = .fullScreen
                self.present(editVC, animated: true)
            }
        }
    }
//   이미지 다운받을때 인덱싱 하여 넘겨주어서 해당 사진 삭제되면 어떤게 삭제되었는지 확인
    private func downloadImages(from urls: [String], completion: @escaping ([UIImage?]) -> Void) {
        var images = [UIImage?](repeating: nil, count: urls.count)
        let dispatchGroup = DispatchGroup()
 
        for (index, urlString) in urls.enumerated() {
            guard let url = URL(string: urlString) else { continue }

            dispatchGroup.enter()
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                defer { dispatchGroup.leave() }
                
                if let data = data, let image = UIImage(data: data) {
                    images[index] = image
                } else {
                    print("Failed to download image from \(urlString): \(error?.localizedDescription ?? "No error information")")
                }
            }
            task.resume()
        }

        dispatchGroup.notify(queue: .main) {
            completion(images)
        }
    }
}
