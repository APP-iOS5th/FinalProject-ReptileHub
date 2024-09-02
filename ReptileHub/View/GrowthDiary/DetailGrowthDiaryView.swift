//
//  DetailGrowthDiaryView.swift
//  ReptileHub
//
//  Created by 이상민 on 9/1/24.
//

import UIKit
import SnapKit

class DetailGrowthDiaryView: UIView {
    
    //MARK: - 특이사항 전체보기 버튼 액션 클로저로 생성
    var detailShowSpecialNoteButtonTapped: (() -> Void)?
    
    //MARK: - 반려 도마뱀 이미지 테두리
    private lazy var detailThumbnailUIView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.groupProfileBG
        view.layer.cornerRadius = 93.5
        view.addSubview(detailThumbnailImageView)
        view.clipsToBounds = true
        return view
    }()
    
    //MARK: - 반려 도마뱀 이미지 뷰
    private lazy var detailThumbnailImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "tempImage")
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 82.5
        view.layer.borderColor = UIColor.textFieldLine.cgColor
        view.layer.borderWidth = 1.0
        view.clipsToBounds = true
        return view
    }()
    
    //MARK: - 반려 도마뱀 이름
    private lazy var detailLiazardNameLabel: UILabel = {
        
        let label = UILabel()
        label.text = "초바"
        label.font = UIFont.systemFont(ofSize: 24)
        label.textColor = UIColor.textFieldTitle
        label.textAlignment = .center
        return label
    }()
    
    //MARK: - 반려 도마뱀 종, 모프 종류
    private lazy var detailLizardSepciesMorphInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "크레스티도 게코, 모프없음"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.textFieldPlaceholder
        label.textAlignment = .center
        return label
    }()
    
    //MARK: - 반려 도마뱀 이름, 종, 모프 종류를 담는 스택 뷰
    private lazy var detailLizardTextStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [detailLiazardNameLabel, detailLizardSepciesMorphInfoLabel])
        view.axis = .vertical
        view.spacing = 6
        return view
    }()
    
    //MARK: - 해칭일 타이틀
    private lazy var detailHatchDaysTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "해칭일"
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor.textFieldPlaceholder
        return label
    }()
    
    //MARK: - 해칭일 날짜
    private lazy var detailHatchDaysLabel: UILabel = {
        let label = UILabel()
        label.text = "24. 08. 05"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    //MARK: - 해칭일 스택 뷰
    private lazy var detailHatchDaysStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [detailHatchDaysTitleLabel, detailHatchDaysLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 4
        return stackView
    }()
    
    //MARK: - 피딩 방식 타이틀
    private lazy var detailFeedMethodTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "피딩방식"
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor.textFieldPlaceholder
        return label
    }()
    
    //MARK: - 피딩 방식
    private lazy var detailFeedMethodLabel: UILabel = {
        let label = UILabel()
        label.text = "자율"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    //MARK: - 피딩 방식 스택 뷰
    private lazy var detailFeedMethodStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [detailFeedMethodTitleLabel, detailFeedMethodLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 4
        return stackView
    }()
    
    //MARK: - 꼬리 타이틀
    private lazy var detailTailTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "꼬리"
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor.textFieldPlaceholder
        return label
    }()
    
    //MARK: - 꼬리 유무
    private lazy var detailTailLabel: UILabel = {
        let label = UILabel()
        label.text = "있음"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    //MARK: - 꼬리 스택 뷰
    private lazy var detailTailStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [detailTailTitleLabel, detailTailLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 4
        return stackView
    }()
    
    //MARK: - 해칭일, 피딩방식, 꼬리정보를 나타내는 스택 뷰
    private lazy var detailLizardSecondStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [detailHatchDaysStackView, detailFeedMethodStackView, detailTailStackView])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.backgroundColor = .addBtnGraphTabbar
        stackView.layer.cornerRadius = CGFloat(5)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    //MARK: - 반려 도마뱀 스택 뷰
    private lazy var detailLizardFirstInfoStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [detailThumbnailUIView, detailLizardTextStackView, detailLizardSecondStackView])
        view.axis = .vertical
        view.spacing = 20
        view.alignment = .center
        return view
    }()
    
    //MARK: - 무게 추이 타이틀
    private lazy var detailWeightTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "무게 추이"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.textFieldTitle
        return label
    }()
    
    //MARK: - 무게 기록하기 버튼
    private lazy var detailWeightAddButton: UIButton = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        let image = UIImage(systemName: "plus", withConfiguration: imageConfig)
        
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        config.title = "기록하기"
        config.baseForegroundColor = UIColor.textFieldPlaceholder
        config.image = image
        config.imagePlacement = .trailing
        config.imagePadding = 5
        config.attributedTitle?.font = UIFont.systemFont(ofSize: 14)
        
        button.configuration = config
        button.contentHorizontalAlignment = .trailing
        
        return button
    }()
    
    //MARK: - 반려 도마뱀 무게 타이틀 + 기록하기 버튼 스택 뷰
    private lazy var detailWeightTitleAddStackview: UIStackView = {
        let view = UIStackView(arrangedSubviews: [detailWeightTitleLabel, detailWeightAddButton])
        view.axis = .horizontal
        return view
    }()
    
    //MARK: - 무게 추이 그래프
    // TODO: 그래프 만들기
    private lazy var detailWeightGraph: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        view.backgroundColor = .textFieldSegmentBG
        return view
    }()
    
    //MARK: - 무게 추이 타이틀 + 그래프 스택 뷰
    private lazy var detailWeightStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [detailWeightTitleAddStackview, detailWeightGraph])
        view.axis = .vertical
        view.spacing = 10
        return view
    }()
    
    //MARK: - 부모 도마뱀 타이틀
    private lazy var detailParentLizardTitle: UILabel = {
        let label = UILabel()
        label.text = "부모 도마뱀"
        label.textColor = UIColor.textFieldTitle
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    //MARK: - 아빠 도마뱀
    private lazy var detailFatherInfoView: UIView = createDetailParentInfo()
    
    //MARK: - 엄마 도마뱀
    private lazy var detailMotherInfoView: UIView = createDetailParentInfo()
    
    //MARK: - 부모 도마뱀 정보 스택 뷰 (아빠 도마뱀 + 엄마 도마뱀)
    private lazy var detailParentInfoStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [detailFatherInfoView, detailMotherInfoView])
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.spacing = 20
        return view
    }()
    
    //MARK: - 부모 도마뱀 스택 뷰 타이틀 + 부모 도마뱀 정보 스택 뷰
    private lazy var detailParentStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [detailParentLizardTitle, detailParentInfoStackView])
        view.axis = .vertical
        view.spacing = 20
        return view
    }()
    
    //MARK: - 특이사항 타이틀
    private lazy var detailSpecialNoteTitle: UILabel = {
        let label = UILabel()
        label.text = "특이사항"
        label.textColor = UIColor.textFieldTitle
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    //MARK: - 특이사항 전체보기 버튼
    private lazy var detailShowSepcialNote: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        config.title = "전체보기"
        config.baseForegroundColor = UIColor.textFieldPlaceholder
        config.attributedTitle?.font = UIFont.systemFont(ofSize: 14)
        
        button.configuration = config
        button.contentHorizontalAlignment = .trailing
        
        button.addAction(UIAction{ [weak self] _ in
            self?.detailShowSpecialNoteButtonTapped?()
        }, for: .touchUpInside)
        
        return button
    }()
    
    //MARK: - 특이상항 헤더 (타이틀 + 전체보기 버튼)
    private lazy var detailSpecialNoteHeaderStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [detailSpecialNoteTitle, detailShowSepcialNote])
        view.axis = .horizontal
        return view
    }()

//    //MARK: - 특이사항 미리보기 스택 뷰
    private lazy var detailPreviewsSpecialNoteStackView: UIStackView = {
       let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        return view
    }()
    
    //MARK: - 디테일 스택 뷰
    private lazy var detailStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [detailLizardFirstInfoStackView, detailWeightStackView, detailParentStackView/*, detailPreviewsSpecialNoteStackView*/])
        view.axis = .vertical
        view.spacing = 30
        return view
    }()
    
    //MARK: - 디테일 contentView
    private lazy var detailContentView: UIView = {
        let view = UIView()
        view.addSubview(detailStackView)
        view.addSubview(detailSpecialNoteHeaderStackView)
        view.addSubview(detailPreviewsSpecialNoteStackView)
        return view
    }()
    
    //MARK: - 디테일 스크롤 뷰
    private lazy var detailScrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.addSubview(detailContentView)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUI(){
        
        self.addSubview(detailScrollView)
//        cellData()
        //디테일 스크롤 뷰
        detailScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        //디테일 content View
        detailContentView.snp.makeConstraints { make in
            make.width.equalTo(detailScrollView)
//            make.height.greaterThanOrEqualToSuperview()
            make.top.equalTo(detailScrollView).offset(30)
            make.bottom.equalTo(detailScrollView).offset(-30)
            make.leading.trailing.equalTo(detailScrollView)
        }
        
        //디테일 스택 뷰
        detailStackView.snp.makeConstraints { make in
            make.top.equalTo(detailContentView)
            make.leading.equalTo(detailContentView.snp.leading).offset(Spacing.mainSpacing)
            make.trailing.equalTo(detailContentView.snp.trailing).offset(-Spacing.mainSpacing)
        }
        
        //반려 도마뱀의 자식 정보 스택 뷰
        detailLizardFirstInfoStackView.snp.makeConstraints { make in
            make.top.equalTo(detailStackView.snp.top)
            make.leading.trailing.equalTo(detailStackView)
        }
        
        //반려 도마뱀의 썸네일 테두리를 나타내는 뷰
        detailThumbnailUIView.snp.makeConstraints { make in
            make.centerX.equalTo(detailLizardFirstInfoStackView)
            make.width.height.equalTo(187)
        }
        
        //반려 도마뱀의 썸네일을 보여주는 UIImageView
        detailThumbnailImageView.snp.makeConstraints { make in
            make.width.height.equalTo(165)
            make.center.equalTo(detailThumbnailUIView)
        }
        
        //반려 도마뱀의 해칭일, 피딩방식, 꼬리를 나타내는 스택 뷰
        detailLizardSecondStackView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(detailLizardFirstInfoStackView)
            make.height.equalTo(80)
        }
        
        //반려 도마뱀 무게 추이 그래프 뷰
        detailWeightStackView.snp.makeConstraints { make in
            make.height.equalTo(200)
        }
        
        detailSpecialNoteHeaderStackView.snp.makeConstraints { make in
            make.top.equalTo(detailStackView.snp.bottom).offset(30)
            make.leading.trailing.equalTo(detailStackView)
        }
        
        detailPreviewsSpecialNoteStackView.snp.makeConstraints { make in
            make.top.equalTo(detailSpecialNoteHeaderStackView.snp.bottom).offset(10)
            make.leading.trailing.equalTo(detailStackView)
            make.bottom.equalTo(detailContentView.snp.bottom).offset(-30)
        }
    }
    
    private func createDetailParentInfo() -> UIView{
        let detailParentImageView = UIImageView()
        detailParentImageView.image = UIImage(named: "tempImage")
        detailParentImageView.contentMode = .scaleAspectFill
        detailParentImageView.clipsToBounds = true
        detailParentImageView.layer.cornerRadius = 5
        detailParentImageView.layer.borderWidth = 1.0
        detailParentImageView.layer.borderColor = UIColor.textFieldBorderLine.cgColor
        detailParentImageView.tag = 0
        
        let detailParentNameLabel = UILabel()
        detailParentNameLabel.text = "아빠 도마뱀 이름"
        detailParentNameLabel.font = UIFont.systemFont(ofSize: 16)
        detailParentNameLabel.textColor = UIColor.textFieldTitle
        detailParentNameLabel.tag = 1
        
        let detailParentSpecialsMorphLabel = UILabel()
        detailParentSpecialsMorphLabel.text = "아빠 도마뱀, 모프없음"
        detailParentSpecialsMorphLabel.textColor = UIColor.textFieldPlaceholder
        detailParentSpecialsMorphLabel.font = UIFont.systemFont(ofSize: 12)
        detailParentSpecialsMorphLabel.tag = 2
        
        let detailParentView = UIView()
        detailParentView.addSubview(detailParentImageView)
        detailParentView.addSubview(detailParentNameLabel)
        detailParentView.addSubview(detailParentSpecialsMorphLabel)
        
        detailParentImageView.snp.makeConstraints { make in
            make.top.equalTo(detailParentView.snp.top)
            make.leading.trailing.equalTo(detailParentView)
            make.height.equalTo(120)
        }
        //
        detailParentNameLabel.snp.makeConstraints { make in
            make.top.equalTo(detailParentImageView.snp.bottom).offset(10)
            make.leading.trailing.equalTo(detailParentView)
        }
        //
        detailParentSpecialsMorphLabel.snp.makeConstraints { make in
            make.top.equalTo(detailParentNameLabel.snp.bottom).offset(2)
            make.leading.trailing.equalTo(detailParentView)
            make.bottom.equalTo(detailParentView)
        }
        
        return detailParentView
    }
    
    func detailAddSepcialNotesCellView(_ cellView: UIView){
        detailPreviewsSpecialNoteStackView.addArrangedSubview(cellView)
    }
    
//    func cellData(){
//        for _ in 0..<3{
//            let cellView = createCellView()
//            detailPreviewsSpecialNoteStackView.addArrangedSubview(cellView)
//        }
//    }
//    
//    func createCellView() -> UIView {
//           // CustomTableViewCell 생성
//           let cell = SpecialListViewCell(style: .default, reuseIdentifier: SpecialListViewCell.identifier)
//           
//           // 셀의 높이를 설정
//           cell.contentView.snp.makeConstraints { make in
//               make.height.equalTo(100)
//           }
//        
//        
//           
//           return cell.contentView
//       }
}

#if DEBUG
import SwiftUI

struct DetailGrowthDiaryViewRepresentable: UIViewRepresentable{
    func makeUIView(context: Context) -> DetailGrowthDiaryView {
        return DetailGrowthDiaryView()
    }
    
    func updateUIView(_ uiView: DetailGrowthDiaryView, context: Context) {
        uiView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}

#Preview(body: {
    DetailGrowthDiaryViewRepresentable()
})
#endif
