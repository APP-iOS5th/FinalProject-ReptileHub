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
    
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
