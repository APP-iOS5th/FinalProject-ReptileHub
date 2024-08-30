//
//  SpecialDetailViewController.swift
//  ReptileHub
//
//  Created by 황민경 on 8/21/24.
//

import UIKit
import SnapKit

class SpecialDetailViewController: UIViewController {
    
    private let specialDetailView = SpecialDetailView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view = specialDetailView
        setupNavigationBar()
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Navigationbar & UIMenu
    private func setupNavigationBar() {
        navigationItem.title = "특이사항"
        
        let ellipsis: UIButton = {
            let ellipsis = UIButton()
            ellipsis.setImage(UIImage(systemName: "ellipsis"), for: .normal)
            ellipsis.tintColor = .darkGray
            ellipsis.contentMode = .center
            ellipsis.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
            return ellipsis
        }()
        var menuItems: [UIAction] {
            return [
                UIAction(title: "수정하기", image: UIImage(systemName: "pencil"),handler: { [weak self]_ in
                    self?.navigateToEditScreen() }),
                UIAction(title: "삭제하기", image: UIImage(systemName: "trash"),attributes: .destructive,handler: { _ in}),
                
            ]
        }
        var menu: UIMenu {
            return UIMenu(title: "", image: nil, identifier: nil, options: [], children: menuItems)
        }
        
        let customBarButtonItem = UIBarButtonItem(customView: ellipsis)
        navigationItem.rightBarButtonItem = customBarButtonItem
        ellipsis.showsMenuAsPrimaryAction = true
        ellipsis.menu = menu
    }
    // 수정 화면으로 전환하는 함수
        private func navigateToEditScreen() {
            let editViewController = SpecialEditViewController()
            navigationController?.pushViewController(editViewController, animated: true)
        }

}
