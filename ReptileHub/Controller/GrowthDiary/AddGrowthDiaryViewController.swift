//
//  AddGrowthDiaryViewController.swift
//  ReptileHub
//
//  Created by 이상민 on 8/27/24.
//

import UIKit

class AddGrowthDiaryViewController: UIViewController {

    private lazy var addGrowthDiaryView = AddGrowthDiaryView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUP()
    }

    func setUP(){
        self.title = "성장일지"
        self.view = addGrowthDiaryView
        self.view.backgroundColor = .white
        
        let action = UIAction{ [weak self] _ in
            self?.datePickerValueChanged()
        }
        addGrowthDiaryView.addAction(action: action)
    }
    
    private func datePickerValueChanged(){
        addGrowthDiaryView.updateDateField()
    }
}

#if DEBUG
import SwiftUI
struct AddViewControllerRepresentable: UIViewControllerRepresentable {
    
    func updateUIViewController(_ uiView: UIViewController,context: Context) {
        // leave this empty
    }
    @available(iOS 13.0.0, *)
    func makeUIViewController(context: Context) -> UIViewController{
        AddGrowthDiaryViewController()
    }
}
@available(iOS 13.0, *)
struct AddViewControllerRepresentable_PreviewProvider: PreviewProvider {
    static var previews: some View {
        Group {
            AddViewControllerRepresentable()
                .ignoresSafeArea()
                .previewDisplayName(/*@START_MENU_TOKEN@*/"Preview"/*@END_MENU_TOKEN@*/)
                .previewDevice(PreviewDevice(rawValue: "iPhone 15 Pro"))
        }
        
    }
} #endif
