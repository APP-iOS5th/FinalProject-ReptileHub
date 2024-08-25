//
//  AddPostViewController.swift
//  ReptileHub
//
//  Created by 조성빈 on 8/23/24.
//

import UIKit

class AddPostViewController: UIViewController {
    
    private let addPostView = AddPostView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        self.view = addPostView
    }
    

 
}
