//
//  GrowthDiaryViewController.swift
//  ReptileHub
//
//  Created by 조성빈 on 8/5/24.
//

import UIKit

class GrowthDiaryViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    let mydata: [Int] = [1, 2, 3, 9, 9 ,9 ,9 ,9] //개수를 파악하기 위한 임시 데이터
    private let GrowthDiaryView = GrowthDiaryListView()
    private lazy var emptyView: EmptyView = {
        return EmptyView()
    }()
    private var thumbnailData: [ThumbnailResponse] = []
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        GrowthDiaryView.updateScrollState()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
//    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        DiaryPostService.shared.fetchGrowthThumbnails(for: "TmIYwsxUilXYTACIGEYXiWomF2I3") { response in
            switch response{
                
            case .success(let thumbnail):
                self.thumbnailData = thumbnail
                print()
                print()
                print()
                print()
                print()
                print(thumbnail)
                self.GrowthDiaryView.GrowthDiaryListCollectionView.reloadData()
                self.GrowthDiaryView.updateScrollState()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        print("abcdegdsafdssdfsdfasdfsdfsdfsdf")
        print(self.thumbnailData)
    }
//    
    private func setUp(){
        self.view = GrowthDiaryView
        GrowthDiaryView.backgroundColor = .white
        GrowthDiaryView.cofigureCollectionView(delegate: self, dataSource: self)
        GrowthDiaryView.reigsterCollectionViewCell(GrowthDiaryListCollectionViewCell.self, forCellWithReuseIdentifier: GrowthDiaryListCollectionViewCell.identifier)
        GrowthDiaryView.buttonTapped = { [weak self] in
            self?.navigateToSecondViewController()
        }
    }
    
    private func navigateToSecondViewController(){
        let secondViewController = AddGrowthDiaryViewController()
        navigationController?.pushViewController(secondViewController, animated: true)
    }
}

//MARK: - Extension
extension GrowthDiaryViewController{
    
    //섹션에 넣을 아이템 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // TODO: 실제 존재하는 Model의 개수
        print("제발",thumbnailData.count)
        print()
        print()
        print()
        print()
        print()
        print("fsdfdasfsdfsdfsdfsdfdsf", self.thumbnailData)
        if self.thumbnailData.count == 0{
            emptyView.configure("등록된 반려도마뱀이 없습니다.")
            collectionView.backgroundView = emptyView
        }else{
            collectionView.backgroundView = nil
        }
        return self.thumbnailData.count
    }
    
    //데이터 소스 개체에 컬레션 보기에서 지정된 항목에 해당하는 셀을 요청합니다.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //as?로 수정여 오류처리하기
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GrowthDiaryListCollectionViewCell.identifier, for: indexPath) as? GrowthDiaryListCollectionViewCell else{
            return UICollectionViewCell()
        }
        
        // TODO: 실제 모델을 넘기고 configure함수에서 .image, .tile. timestamp로 cell에 넣기
        cell.configure(imageName: thumbnailData[indexPath.item].thumbnail, title: thumbnailData[indexPath.item].name, date: thumbnailData[indexPath.item].diary_id)
        return cell
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
