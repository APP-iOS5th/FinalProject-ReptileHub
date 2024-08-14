//
//  GrowthDiaryViewController.swift
//  ReptileHub
//
//  Created by 조성빈 on 8/5/24.
//

import UIKit

class GrowthDiaryViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    private let GrowthDiaryView = GrowthDiaryListView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = GrowthDiaryView
        GrowthDiaryView.backgroundColor = .white
        GrowthDiaryView.cofigureCollectionView(delegate: self, dataSource: self)
        GrowthDiaryView.reigsterCollectionViewCell(GrowthDiaryListCollectionViewCell.self, forCellWithReuseIdentifier: GrowthDiaryListCollectionViewCell.identifier)
    }
}

//MARK: - Extension
extension GrowthDiaryViewController{
    //섹션에 넣을 아이템 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        10//임시
    }
    
    //데이터 소스 개체에 컬레션 보기에서 지정된 항목에 해당하는 셀을 요청합니다.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //as?로 수정여 오류처리하기
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GrowthDiaryListCollectionViewCell.identifier, for: indexPath) as? GrowthDiaryListCollectionViewCell else{
            return UICollectionViewCell()
        }
        return cell
    }
    
    //대리인에게 지정된 항목의 셀의 크기를 요청합니다.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 20
        let width = (collectionView.bounds.width - padding) / 2
        // TODO: 높이 계산하기
        let heigth = 171.0
        return CGSize(width: width, height: heigth)
        
    }
}


#if DEBUG
import SwiftUI
struct ViewControllerRepresentable: UIViewControllerRepresentable {
    
    func updateUIViewController(_ uiView: UIViewController,context: Context) {
        // leave this empty
    }
    @available(iOS 13.0.0, *)
    func makeUIViewController(context: Context) -> UIViewController{
        GrowthDiaryViewController()
    }
}
@available(iOS 13.0, *)
struct ViewControllerRepresentable_PreviewProvider: PreviewProvider {
    static var previews: some View {
        Group {
            ViewControllerRepresentable()
                .ignoresSafeArea()
                .previewDisplayName(/*@START_MENU_TOKEN@*/"Preview"/*@END_MENU_TOKEN@*/)
                .previewDevice(PreviewDevice(rawValue: "iPhone 15 Pro"))
        }
        
    }
} #endif
