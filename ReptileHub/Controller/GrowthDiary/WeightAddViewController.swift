//
//  WeightAddViewController.swift
//  ReptileHub
//
//  Created by 이상민 on 9/6/24.
//

import UIKit

class WeightAddViewController: UIViewController {

    private lazy var addWeightView = AddWeightView()
    
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
    }
    
    private func cancelAddViewController(){
        print("a")
        dismiss(animated: true)
    }
}
