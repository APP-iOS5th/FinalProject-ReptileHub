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
        DiaryPostService.shared.fetchGrowthThumbnails(for: UserService.shared.currentUserId) {[weak self] response in
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
        let secondViewController = AddGrowthDiaryViewController(editMode: false)
        secondViewController.previousViewController = self
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
        
        // TODO: 여기 생성할때 넘기 날짜가 오게 해야함
        cell.configure(imageName: thumbnailData[indexPath.item].thumbnail, title: thumbnailData[indexPath.item].name, date: Date().formatted)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailGrowthDiaryVicontroller = DetailGrowthDiaryViewController(diaryID: thumbnailData[indexPath.item].diary_id, lizardName: thumbnailData[indexPath.item].name)
        detailGrowthDiaryVicontroller.previousVC = self
        self.navigationController?.pushViewController(detailGrowthDiaryVicontroller, animated: true)
    }
}
