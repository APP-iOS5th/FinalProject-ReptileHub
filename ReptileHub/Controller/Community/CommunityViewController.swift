//
//  CommunityViewController.swift
//  ReptileHub
//
//  Created by 조성빈 on 8/5/24.
//

import UIKit
import SnapKit

class CommunityViewController: UIViewController {
    
    private var searchButton: UIBarButtonItem = UIBarButtonItem()


    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        title = "커뮤니티"
        
        setupSearchButton()
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
