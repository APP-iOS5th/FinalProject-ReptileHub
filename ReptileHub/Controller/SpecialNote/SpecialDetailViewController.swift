//
//  SpecialDetailViewController.swift
//  ReptileHub
//
//  Created by 황민경 on 8/21/24.
//

import UIKit
import SnapKit

protocol SpecialDetailViewDelegate: AnyObject {
    func deleteSpecialNoteButtonTapped(data: DiaryResponse)
}

class SpecialDetailViewController: UIViewController {
    
    var diaryID: String
    
    var delegate: SpecialDetailViewDelegate?
    private let specialDetailView = SpecialDetailView()
    let saveSpecialData: DiaryResponse
    init(saverEntries: DiaryResponse, diaryID: String) {
        self.saveSpecialData = saverEntries
        self.diaryID = diaryID
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view = specialDetailView
        setupNavigationBar()
        specialDetailView.writeSpecialDetail(data: saveSpecialData)
        print(saveSpecialData)
    }
    
    //TODO: diaryID, LizardName 데이터 받아오기 (넘겨주숑)
    
    //MARK: - Navigationbar & UIMenu
    private func setupNavigationBar() {
        navigationItem.title = "특이사항"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
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
                UIAction(title: "삭제하기", image: UIImage(systemName: "trash"),attributes: .destructive,handler: { [weak self] _ in
                    guard let deleteData = self?.saveSpecialData else { return }
                    self?.delegate?.deleteSpecialNoteButtonTapped(data: deleteData)
                }),
                
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
            let editViewController = SpecialEditViewController(diaryID: diaryID , editMode: true)
            editViewController.editEntry = saveSpecialData
            navigationController?.pushViewController(editViewController, animated: true)
        }

}
