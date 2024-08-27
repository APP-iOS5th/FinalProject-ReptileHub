//
//  SpecialEditViewController.swift
//  ReptileHub
//
//  Created by 황민경 on 8/21/24.
//

import UIKit
import SnapKit

class SpecialEditViewController: UIViewController {
    
    private let specialEditView = SpecialEditView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = specialEditView
        
        navigationItem.title = "특이사항"
        // Do any additional setup after loading the view.
    }
    

}
