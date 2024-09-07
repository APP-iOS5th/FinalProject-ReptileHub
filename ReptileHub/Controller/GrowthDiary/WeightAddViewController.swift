//
//  WeightAddViewController.swift
//  ReptileHub
//
//  Created by 이상민 on 9/6/24.
//

import UIKit

class WeightAddViewController: UIViewController {

    private lazy var addWeightView = AddEditWeightView()
    weak var previousVC: WeightAddEditViewController?
    var diaryID: String
    var editMode: Bool
    var weightData: WeightEntry?
    
    init(diaryID: String, editMode: Bool) {
        self.diaryID = diaryID
        self.editMode = editMode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
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
        
        if let weight = weightData{
            addWeightView.configureAddEditWeightView(weightData: weight)
        }
    }
    
    //MARK: - 취소 버튼 클릭 함수
    private func cancelAddViewController(){
        dismiss(animated: true)
    }
    
    //MARK: - 추가 버튼 클릭 함수
    private func AddWeightEntry(){
        let request = addWeightView.addWeightRequest()
        if editMode{
            guard let weightID = weightData?.id else { return }
            DiaryPostService.shared.updateWeightEntry(userID: UserService.shared.currentUserId, diaryID: diaryID, weightID: weightID, newWeight: request.0, newDate: request.1) { [weak self] error in
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
        }else{
            DiaryPostService.shared.addWeightEntry(userID: UserService.shared.currentUserId, diaryID: diaryID, weight: request.0, date: request.1) { [weak self] error in
                if let error = error{
                    print("ERROR: \(error.localizedDescription)")
                }else{
                    if let previousVC = self?.previousVC{
                        print("추가 성공")
                        previousVC.updateWeightData()
                    }
                    self?.dismiss(animated: true)
                }
            }
        }
    }
}
