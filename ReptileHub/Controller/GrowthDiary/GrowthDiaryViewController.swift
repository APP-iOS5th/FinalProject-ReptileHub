//
//  GrowthDiaryViewController.swift
//  ReptileHub
//
//  Created by 조성빈 on 8/5/24.
//

import UIKit
import FirebaseAuth

class GrowthDiaryViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    private let GrowthDiaryView = GrowthDiaryListView()
    private lazy var emptyView: EmptyView = {
        return EmptyView()
    }()
    private var shouldReloadImage = false
    
    private var thumbnailData = [ThumbnailResponse]()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        GrowthDiaryView.updateScrollState()
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        if shouldReloadImage {
            self.loadData()
            shouldReloadImage = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    private func setUp(){
        self.view = GrowthDiaryView
        GrowthDiaryView.backgroundColor = .white
        GrowthDiaryView.cofigureCollectionView(delegate: self, dataSource: self)
        GrowthDiaryView.reigsterCollectionViewCell(GrowthDiaryListCollectionViewCell.self, forCellWithReuseIdentifier: GrowthDiaryListCollectionViewCell.identifier)
        GrowthDiaryView.buttonTapped = { [weak self] in
            self?.navigateToSecondViewController()
        }
        loadData()
    }
    
    func loadData(){
        guard let userId = Auth.auth().getUserID() else {
            return
        }
        
        DiaryPostService.shared.fetchGrowthThumbnails(for: userId) {[weak self] response in
            switch response{
                
            case .success(let data):
                self?.thumbnailData = data
                self?.GrowthDiaryView.GrowthDiaryListCollectionView.reloadData()
                self?.GrowthDiaryView.updateScrollState()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func updateImage() {
        // 다른 뷰 컨트롤러에서 돌아왔을 때 이미지를 다시 로드해야 하는 경우
        shouldReloadImage = true
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
        if thumbnailData.count == 0{
            emptyView.configure("등록된 반려도마뱀이 없습니다.")
            collectionView.backgroundView = emptyView
        }else{
            collectionView.backgroundView = nil
        }
        return thumbnailData.count
    }
    
    //데이터 소스 개체에 컬레션 보기에서 지정된 항목에 해당하는 셀을 요청합니다.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //as?로 수정여 오류처리하기
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GrowthDiaryListCollectionViewCell.identifier, for: indexPath) as? GrowthDiaryListCollectionViewCell else{
            return UICollectionViewCell()
        }
        
        cell.configure(imageName: thumbnailData[indexPath.item].thumbnail, title: thumbnailData[indexPath.item].name, date: thumbnailData[indexPath.item].diary_id)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailGrowthDiaryVicontroller = DetailGrowthDiaryViewController()
        self.navigationController?.pushViewController(detailGrowthDiaryVicontroller, animated: true)
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
