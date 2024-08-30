//
//  TestVC -BookmarkPostsViewController.swift
//  ReptileHub
//
//  Created by 임재현 on 8/28/24.
//

import UIKit
import Firebase

class BookmarkToggleViewController: UIViewController {

    private let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Bookmark", for: .normal) // 초기 상태: 북마크되지 않은 상태
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8.0
        button.addTarget(self, action: #selector(toggleBookmark), for: .touchUpInside)
        return button
    }()
    
    private let userID = "XYmrUBcFhjdYZSM8TFihX0QNN7O2"
    private let postID = "0E9C6F79-6C8F-4E61-A2C5-AE6A1EEE9560"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        checkInitialBookmarkStatus()  // 초기 북마크 상태 확인
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(bookmarkButton)

        bookmarkButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bookmarkButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bookmarkButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            bookmarkButton.widthAnchor.constraint(equalToConstant: 150),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func toggleBookmark() {
        
        
        CommunityService.shared.toggleBookmarkPost(userID: userID, postID: postID) { [weak self] result in
            switch result {
            case .success(let isBookmarked):
                DispatchQueue.main.async {
                    if isBookmarked {
                        self?.bookmarkButton.setTitle("Unbookmark", for: .normal)
                    } else {
                        self?.bookmarkButton.setTitle("Bookmark", for: .normal)
                    }
                }
            case .failure(let error):
                print("Error toggling bookmark: \(error.localizedDescription)")
            }
        }
    }
    
    private func checkInitialBookmarkStatus() {
        CommunityService.shared.isPostBookmarked(userID: userID, postID: postID) { [weak self] isBookmarked in
            DispatchQueue.main.async {
                if isBookmarked {
                    self?.bookmarkButton.setTitle("Unbookmark", for: .normal)
                } else {
                    self?.bookmarkButton.setTitle("Bookmark", for: .normal)
                }
            }
        }
    }
}

