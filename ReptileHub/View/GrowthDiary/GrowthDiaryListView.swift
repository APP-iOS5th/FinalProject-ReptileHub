//
//  GrowthDiaryListView.swift
//  ReptileHub
//
//  Created by 이상민 on 8/12/24.
//

import UIKit
import SnapKit

class GrowthDiaryListView: UIView {    
    //MARK: - 상단 텍스트 Label
    private lazy var GrowthDiaryTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "사랑하는 반려도마뱀의 하루하루를 기록해보세요!"
        label.font = UIFont.systemFont(ofSize: 28)
        label.numberOfLines = 0
        label.asFont(rangeText: "하루하루를 기록해보세요!", font: UIFont.systemFont(ofSize: 28, weight: .bold))
        return label
    }()
    
    //MARK: - 성장일지 목록 CollectionView
    private lazy var GrowthDiaryListCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        view.showsVerticalScrollIndicator = false //수직 스크롤표시 없애기
        return view
    }()
    
    //MARK: - 성장일지 등록페이지 이동 버튼
    private lazy var GrowthDiaryUploadViewMoveButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        
        var config = UIButton.Configuration.filled()
        
        //AttributedString 설정
        var buttonText = AttributedString("새로운 반려 도마뱀 등록하기") //텍스트 정의
        
        //AttributeContainer 생성 및 폰트, 색상 설정
        var attributes = AttributeContainer()
        attributes.font = UIFont.systemFont(ofSize: 18, weight: .semibold) //폰트크기 설정
        
        //AttributedString에 속성 적용
        buttonText.mergeAttributes(attributes)
        
        config.attributedTitle = buttonText
        // TODO: ColorSet으로 설정해서 사용하기
        config.baseBackgroundColor = UIColor(red: 11.0/255.0, green: 71.0/255.0, blue: 59.0/255.0, alpha: 1.0)
        config.baseForegroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 0, bottom: 14, trailing: 0)
        button.configuration = config
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUI()
    }
    
    private func setUI(){
        self.addSubview(GrowthDiaryTitleLabel)
        self.addSubview(GrowthDiaryListCollectionView)
        self.addSubview(GrowthDiaryUploadViewMoveButton)
        
        GrowthDiaryTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(self).offset(Spacing.mainSpacing)
            make.trailing.equalTo(self).offset(-Spacing.mainSpacing)
            make.top.equalTo(self.safeAreaLayoutGuide).offset(40)
        }
        
        GrowthDiaryListCollectionView.snp.makeConstraints { make in
            make.top.equalTo(GrowthDiaryTitleLabel.snp.bottom).offset(30)
            make.leading.equalTo(self).offset(Spacing.mainSpacing)
            make.trailing.equalTo(self).offset(-Spacing.mainSpacing)
            make.bottom.equalTo(GrowthDiaryUploadViewMoveButton.snp.top).offset(-30)
        }
        
        GrowthDiaryUploadViewMoveButton.snp.makeConstraints { make in
            make.leading.equalTo(self).offset(Spacing.mainSpacing)
            make.trailing.equalTo(self).offset(-Spacing.mainSpacing)
            make.bottom.equalTo(self.safeAreaLayoutGuide).offset(-30)
        }
    }
    
    //MARK: - Methods
    func cofigureCollectionView(delegate: UICollectionViewDelegate, dataSource: UICollectionViewDataSource){
        GrowthDiaryListCollectionView.delegate = delegate
        GrowthDiaryListCollectionView.dataSource = dataSource
        GrowthDiaryListCollectionView.reloadData()
    }
    
    func reigsterCollectionViewCell(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String){
        self.GrowthDiaryListCollectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    private func createLayout() -> UICollectionViewLayout{
        // 아이템 크기 설정
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5), // 전체 너비의 50%
            heightDimension: .estimated(200)) // 높이는 동적 설정
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // 그룹 크기 설정
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0)
            , heightDimension: .estimated(200))
        
        //그룹 방향 및 개수 설정
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item, item])
        
        // 그룹 내 아이템 간 간격 설정(열 사이 간격 20p)
        group.interItemSpacing = .fixed(20)
        
        // 섹션 설정
        let section = NSCollectionLayoutSection(group: group)
        // 섹션 내 그룹 간 간격 설정 (행 사이 간격 30p)
        section.interGroupSpacing = 30
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func updateScrollState(){
        GrowthDiaryListCollectionView.setNeedsLayout()
        GrowthDiaryListCollectionView.layoutIfNeeded()
        
        if GrowthDiaryListCollectionView.contentSize.height > GrowthDiaryListCollectionView.bounds.height{
            GrowthDiaryListCollectionView.isScrollEnabled = true
        }else{
            GrowthDiaryListCollectionView.isScrollEnabled = false
        }
    }
}

//MARK: - extension
extension UILabel{
    func asFont(rangeText: String, font: UIFont){
        guard let text = self.text else { return }
        
        let attributeString = NSMutableAttributedString(string: text)
        let range = (text as NSString).range(of: rangeText)
        attributeString.addAttribute(.font, value: font, range: range)
        self.attributedText = attributeString
    }
}

extension UICollectionView{
    func setEmptyView(){
        let emptyMessageLabel: UILabel = {
            let label = UILabel()
            label.text = "등록된 반려도마뱀이 없어요"
            label.textColor = UIColor(red: 215/255, green: 215/255, blue: 215/255, alpha: 1)
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 20)
            return label
        }()
        self.backgroundView = emptyMessageLabel
    }
    
    func restore(){
        self.backgroundView = nil
    }
}

#if DEBUG
import SwiftUI

struct GrowthDiaryListViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> GrowthDiaryListView {
        return GrowthDiaryListView()
    }
    
    func updateUIView(_ uiView: GrowthDiaryListView, context: Context) {
        // 필요하다면 뷰 업데이트
        uiView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}

struct MyCustomView_Previews: PreviewProvider {
    static var previews: some View {
        GrowthDiaryListViewRepresentable()
            .previewLayout(.sizeThatFits) // 크기를 맞춤 설정할 수 있음
    }
}
#endif
