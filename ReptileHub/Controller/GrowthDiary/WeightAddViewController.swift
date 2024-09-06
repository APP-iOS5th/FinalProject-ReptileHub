//
//  WeightAddViewController.swift
//  ReptileHub
//
//  Created by 이상민 on 9/6/24.
//

import UIKit

class WeightAddViewController: UIViewController {

    private lazy var addWeightView = AddWeightView()
    var previousVC: WeightAddEditViewController?
    var diaryID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUP()
    }
    
    private func setUP(){
        self.view = addWeightView
        self.view.backgroundColor = .white
        addWeightView.cancelButtonTapped = { [weak self] in
            self?.cancelAddViewController()
        }
        addWeightView.addButtonTapped = { [weak self] in
            self?.AddWeightEntry()
        }
    }
    
    //MARK: - 취소 버튼 클릭 함수
    private func cancelAddViewController(){
        dismiss(animated: true)
    }
    
    //MARK: - 추가 버튼 클릭 함수
    private func AddWeightEntry(){
        let weight = addWeightView.weightData()
        guard let diaryID = diaryID else { return}
        // TODO: 날짜는 안보내도 되는건지
        DiaryPostService.shared.addWeightEntry(userID: UserService.shared.currentUserId, diaryID: diaryID, weight: weight) { [weak self] error in
            if let error = error{
                print("ERROR: \(error.localizedDescription)")
            }else{
                if let previousVC = self?.previousVC{
                    print("업데이트")
                    previousVC.updateWeightData()
                }
                self?.dismiss(animated: true)
            }
        }
    }
}
