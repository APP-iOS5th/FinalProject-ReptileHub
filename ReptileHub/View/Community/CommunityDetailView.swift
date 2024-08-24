//
//  CommunityDetailView.swift
//  ReptileHub
//
//  Created by 조성빈 on 8/22/24.
//

import UIKit
import SnapKit

class CommunityDetailView: UIView {
    
    var dummyData = ["동해물과 백두산이 마르도 닳도록 하느님이 보우하사 우리나라 만세. 무궁화 삼천리 화려강산 대한사람 대한으로 부디 보전하세.", "커뮤니티 상세 페이지 댓글 테이블 뷰 동적 크기 조절. 테이블 뷰 내의 셀들의 높이가 각각 달라지는 상황에서 테이블 뷰를 스크롤되지않고, 셀들의 크기의 합을 테이블 뷰 높이의 합으로 가져가면서 테이블 뷰가 아닌 스크롤 뷰에서 스크롤 할 수 있도록 구현하고싶다..~~", "링딩동", "다크초코 6.7만 달성~", "커뮤니티 상세 페이지 댓글 테이블 뷰 동적 크기 조절. 테이블 뷰 내의 셀들의 높이가 각각 달라지는 상황에서 테이블 뷰를 스크롤되지않고, 셀들의 크기의 합을 테이블 뷰 높이의 합으로 가져가면서 테이블 뷰가 아닌 스크롤 뷰에서 스크롤 할 수 있도록 구현하고싶다..~~커뮤니티 상세 페이지 댓글 테이블 뷰 동적 크기 조절. 테이블 뷰 내의 셀들의 높이가 각각 달라지는 상황에서 테이블 뷰를 스크롤되지않고, 셀들의 크기의 합을 테이블 뷰 높이의 합으로 가져가면서 테이블 뷰가 아닌 스크롤 뷰에서 스크롤 할 수 있도록 구현하고싶다..~~",]
    
    // 키보드 탭 제스쳐
    lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
    
    // 스크롤 뷰
    private let scrollView: UIScrollView = UIScrollView()
    private let stackView: UIStackView = UIStackView()
    
    // 상단 게시글 정보
    private let profileImage: UIImageView = UIImageView()
    
    private let titleLabel: UILabel = UILabel()
    private let nicknameLabel: UILabel = UILabel()
    private let timestampLabel: UILabel = UILabel()
    private let elementStackView: UIStackView = UIStackView()
    
    private let likeButton: UIButton = UIButton()
    
    private var menuButton: UIBarButtonItem = UIBarButtonItem()
    
    private let titleStackView: UIStackView = UIStackView()
    
    // 상단 게시글 정보와 게시글 본문 사이의 구분선
    private let divisionLine: UIView = UIView()
    
    // 본문 이미지
    private let contentImages: [UIImageView] = [
        UIImageView(image: UIImage(named: "choba")),
        UIImageView(image: UIImage(named: "cookie")),
        UIImageView(image: UIImage(named: "cookie")),
    ]
    private var imageViews: [UIView] = []
    private let imageStackView: UIStackView = UIStackView()
    private let imageScrollView: UIScrollView = UIScrollView()
    // 이미지 개수 나타내는 UI
    private let imagePageCount: UILabel = UILabel()
    private let pageCountView: UIView = UIView()
    
    // 본문 텍스트
    private let contentText: UILabel = UILabel()
    
    // 좋아요, 댓글 개수
    private let likeCount: UILabel = UILabel()
    private let commentCount: UILabel = UILabel()
    private let countInfoStackView: UIStackView = UIStackView()
    
    // 본문과 댓글 구분선
    private let divisionThickLine: UIView = UIView()
    
    // 댓글 부분
    private let commentTableView: UITableView = UITableView(frame: .zero)
    
    // 댓글의 높이를 계산하기위한 변수
    private var tableViewHeight: CGFloat = 0.0
    private var rowHeights: [IndexPath: CGFloat] = [:]
    
    // 댓글 작성란
    private let commentBackgroundView: UIView = UIView()
    private let commentTextView: UITextView = UITextView()
    private let sendButton: UIButton = UIButton()
    private let placeHolder: UILabel = UILabel()
    
    
    let keyboardManager = KeyboardManager()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addGestureRecognizer(tapGesture)
        
        keyboardManager.delegate = self
        keyboardManager.showNoti()
        keyboardManager.hideNoti()
        
        setupCommentView()
        setupMainScrollView()
        setupProfileImage()
        setupElementStackView()
        setupTitleStackView()
        setupDivisionLine()
        setupImageScrollView()
        setupImagePageCountLabel()
        setupTextView()
        setupCountInfoStackView()
        setupDivisionThickLine()
        setupCommentTableView()
        
    }
    
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // super view 클릭시 키보드 내려감
    @objc
    func tapHandler(_ sender: UIView) {
        commentTextView.resignFirstResponder()
    }

    
    
    //MARK: - 스크롤뷰 세팅
    private func setupMainScrollView() {
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .green
        
        stackView.axis = .vertical
        stackView.distribution = .equalCentering
        stackView.alignment = .firstBaseline
        stackView.backgroundColor = .red
        
        self.addSubview(scrollView)
        
        scrollView.addSubview(stackView)
        
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            make.bottom.equalTo(commentBackgroundView.snp.top)
            make.width.equalTo(self.frame.width)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.snp.width)
        }
        
        let stackViewHeight = stackView.heightAnchor.constraint(greaterThanOrEqualTo: self.heightAnchor)
        stackViewHeight.priority = .defaultLow
        stackViewHeight.isActive = true
    }
    
    //MARK: - 프로필 이미지
    private func setupProfileImage() {
        profileImage.image = UIImage(systemName: "person")
        profileImage.backgroundColor = .green
        profileImage.layer.cornerRadius = 30
        profileImage.clipsToBounds = true
    }
    
    //MARK: - 제목, 닉네임, 시간 StackView(elementStackView)
    private func setupElementStackView() {
        titleLabel.text = "공부는 최대한 미뤄라."
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        nicknameLabel.text = "공부싫어"
        nicknameLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        timestampLabel.text = "24.08.09 17:31"
        timestampLabel.font = UIFont.systemFont(ofSize: 10, weight: .light)
        timestampLabel.textColor = UIColor.lightGray
        
        elementStackView.axis = .vertical
        elementStackView.distribution = .fillEqually
        elementStackView.alignment = .leading
        elementStackView.backgroundColor = .systemPink
        
        elementStackView.addArrangedSubview(titleLabel)
        elementStackView.addArrangedSubview(nicknameLabel)
        elementStackView.addArrangedSubview(timestampLabel)
    }
    
    
    //MARK: - title StackView + 좋아요 버튼
    private func setupTitleStackView() {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        let heartImage = UIImage(systemName: "heart", withConfiguration: imageConfig)
        
        likeButton.setImage(heartImage, for: .normal)
        
        likeButton.snp.makeConstraints { make in
            make.width.equalTo(40)
        }
        
        titleStackView.axis = .horizontal
        titleStackView.distribution = .fill
        titleStackView.alignment = .center
        titleStackView.spacing = 10
        titleStackView.backgroundColor = .yellow
        
        titleStackView.addArrangedSubview(profileImage)
        titleStackView.addArrangedSubview(elementStackView)
        titleStackView.addArrangedSubview(likeButton)
        
        self.stackView.addArrangedSubview(titleStackView)
        
        titleStackView.snp.makeConstraints { make in
            make.top.equalTo(self.stackView.snp.top)
            make.leading.equalTo(self.stackView.snp.leading).offset(24)
            make.trailing.equalTo(self.stackView.snp.trailing).offset(-24)
            make.height.equalTo(60)
        }
        
        profileImage.snp.makeConstraints { make in
            make.height.width.equalTo(60)
            make.leading.equalTo(titleStackView.snp.leading)
        }
        
        elementStackView.snp.makeConstraints { make in
            make.leading.equalTo(profileImage.snp.trailing).offset(10)
            make.trailing.equalTo(titleStackView.snp.trailing)
            make.height.equalTo(50)
        }
    }
    
    //MARK: - 제목, 본문과의 구분선
    private func setupDivisionLine() {
        divisionLine.backgroundColor = .lightGray
        
        self.stackView.addArrangedSubview(divisionLine)
        
        divisionLine.snp.makeConstraints { make in
            make.height.equalTo(0.5)
            make.top.equalTo(titleStackView.snp.bottom).offset(12)
            make.leading.equalTo(self.stackView.snp.leading)
            make.trailing.equalTo(self.stackView.snp.trailing)
        }
    }
    
    //MARK: - 본문 이미지, 스크롤뷰
    private func setupImageScrollView() {
        imageStackView.axis = .horizontal
        imageStackView.distribution = .fillEqually
        imageStackView.alignment = .center
        imageStackView.backgroundColor = .green
        
        imageScrollView.alwaysBounceHorizontal = true
        imageScrollView.isPagingEnabled = true
        imageScrollView.backgroundColor = .blue
        
        self.stackView.addArrangedSubview(imageScrollView)
        
        imageScrollView.snp.makeConstraints { make in
            make.height.equalTo(230)
            make.width.equalTo(self)
            make.top.equalTo(divisionLine.snp.bottom).offset(12)
            make.leading.equalTo(self.stackView.snp.leading)
            make.trailing.equalTo(self.stackView.snp.trailing)
        }
        
        imageScrollView.addSubview(imageStackView)
        
        imageStackView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalTo(imageScrollView)
        }
        
        for i in 0..<contentImages.count {
            let imageView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 230))
            
            contentImages[i].contentMode = .scaleAspectFit
            
            imageView.addSubview(contentImages[i])
            
            contentImages[i].snp.makeConstraints { make in
                make.centerX.equalTo(imageView)
                make.height.equalTo(230)
            }
            
            imageViews.append(imageView)
        }
        
        for imageView in imageViews {
            imageView.backgroundColor = .gray
            imageStackView.addArrangedSubview(imageView)
            
            imageView.snp.makeConstraints { make in
                make.height.equalTo(230)
                make.width.equalTo(imageScrollView)
            }
            
        }
        
        
    }
    
    //MARK: - 본문 이미지의 페이지 현황
    private func setupImagePageCountLabel() {
        pageCountView.backgroundColor = .lightGray
        pageCountView.layer.cornerRadius = 12
        
        pageCountView.addSubview(imagePageCount)
        
        self.stackView.addArrangedSubview(pageCountView)
        
        pageCountView.snp.makeConstraints { make in
            make.height.equalTo(27)
            make.width.equalTo(40)
            make.trailing.equalTo(imageScrollView.snp.trailing).offset(-10)
            make.bottom.equalTo(imageScrollView.snp.bottom).offset(-10)
        }
        
        imagePageCount.text = "1/\(contentImages.count)"
        imagePageCount.backgroundColor = .lightGray
        
        imagePageCount.snp.makeConstraints { make in
            make.centerX.equalTo(pageCountView)
            make.centerY.equalTo(pageCountView)
        }
    }
    
    //MARK: - 본문 내용
    private func setupTextView() {
        contentText.text = "게시글 본문 예시 내용입니다."
        contentText.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        contentText.backgroundColor = .lightGray
        
        self.stackView.addArrangedSubview(contentText)
        
        contentText.snp.makeConstraints { make in
            make.top.equalTo(imageScrollView.snp.bottom).offset(10)
            make.leading.trailing.equalTo(titleStackView)
            make.height.greaterThanOrEqualTo(80)
        }
    }
    
    //MARK: - count info stackview - 좋아요, 댓글 수 스택뷰
    private func setupCountInfoStackView() {
        let likeImage = UIImageView(image: UIImage(systemName: "heart"))
        let commentImage = UIImageView(image: UIImage(systemName: "message"))
        
        countInfoStackView.axis = .horizontal
        countInfoStackView.distribution = .fill
        countInfoStackView.spacing = 5
        countInfoStackView.alignment = .center
        
        likeCount.text = "123"
        commentCount.text = "123"
        
        countInfoStackView.addArrangedSubview(likeImage)
        countInfoStackView.addArrangedSubview(likeCount)
        countInfoStackView.addArrangedSubview(commentImage)
        countInfoStackView.addArrangedSubview(commentCount)
        
        self.stackView.addArrangedSubview(countInfoStackView)
        
        countInfoStackView.snp.makeConstraints { make in
            make.top.equalTo(contentText.snp.bottom).offset(10)
            make.leading.equalTo(contentText.snp.leading)
            make.height.equalTo(20)
        }
    }
    
    //MARK: - 본문과 댓글 사이의 구분선(두꺼움)
    private func setupDivisionThickLine() {
        divisionThickLine.backgroundColor = .lightGray
        
        self.stackView.addArrangedSubview(divisionThickLine)
        
        divisionThickLine.snp.makeConstraints { make in
            make.height.equalTo(10)
            make.top.equalTo(countInfoStackView.snp.bottom).offset(10)
            make.leading.trailing.equalTo(self)
            
        }
    }
    
    //MARK: - 댓글 테이블 뷰
    private func setupCommentTableView() {
        let headerView: UILabel = UILabel()
        headerView.text = "댓글"
        headerView.backgroundColor = .yellow
        headerView.frame = CGRect(x: 0, y: 0, width: 0, height: 40)
        
        
        commentTableView.register(CommentTableViewCell.self, forCellReuseIdentifier: "commentCell")
        commentTableView.isScrollEnabled = false
        commentTableView.backgroundColor = .lightGray
        commentTableView.estimatedRowHeight = 60
        commentTableView.rowHeight = UITableView.automaticDimension
        commentTableView.tableHeaderView = headerView
        
        self.stackView.addArrangedSubview(commentTableView)
        
        commentTableView.translatesAutoresizingMaskIntoConstraints = false
        
        var resultHeight: CGFloat = 0.0
        
        for comment in dummyData {
            let height = getLabelHeight(tableView: commentTableView,text: comment)
            resultHeight += height
        }
        
        commentTableView.snp.makeConstraints { make in
            make.top.equalTo(divisionThickLine.snp.bottom)
            make.leading.equalTo(self.stackView.snp.leading).offset(24)
            make.trailing.equalTo(self.stackView.snp.trailing).offset(-24)
            make.bottom.equalTo(self.stackView.snp.bottom)
            make.height.equalTo(resultHeight)
        }
    }
    
    
    
    //MARK: - 댓글 작성란 setup
    private func setupCommentView() {
        commentTextView.layer.cornerRadius = 10
        commentTextView.font = UIFont.systemFont(ofSize: 18)
        commentTextView.isScrollEnabled = false
        commentTextView.textContainer.lineFragmentPadding = 15
        commentTextView.backgroundColor = .lightGray
        
        placeHolder.text = "댓글을 남겨보세요"
        placeHolder.font = UIFont.systemFont(ofSize: 18, weight: .light)
        placeHolder.textColor = .white
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 25)
        let planeImage = UIImage(systemName: "paperplane.fill", withConfiguration: imageConfig)
        sendButton.setImage(planeImage, for: .normal)
        
        commentBackgroundView.backgroundColor = .gray
        
        self.addSubview(commentBackgroundView)
        
        commentBackgroundView.snp.makeConstraints { make in
            make.width.equalTo(self.frame.width)
            make.height.greaterThanOrEqualTo(40)
            make.leading.trailing.equalTo(self)
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
        }
        
        commentBackgroundView.addSubview(commentTextView)
        commentBackgroundView.addSubview(sendButton)
        commentTextView.addSubview(placeHolder)
        
        sendButton.snp.makeConstraints { make in
            make.trailing.equalTo(commentBackgroundView.snp.trailing)
            make.bottom.equalTo(commentBackgroundView.snp.bottom).offset(-3)
            make.height.width.equalTo(40)
        }
        
        commentTextView.snp.makeConstraints { make in
            make.top.equalTo(commentBackgroundView.snp.top).offset(5)
            make.leading.equalTo(commentBackgroundView.snp.leading).offset(10)
            make.trailing.equalTo(sendButton.snp.leading)
            make.bottom.equalTo(commentBackgroundView.snp.bottom).offset(-5)
            make.height.greaterThanOrEqualTo(40) // 최소 높이를 40으로 설정
            make.height.lessThanOrEqualTo(103)
            make.width.equalTo(342)
        }
        
        placeHolder.snp.makeConstraints { make in
            make.centerY.equalTo(commentTextView)
            make.leading.equalTo(commentTextView.snp.leading).offset(15)
        }
    }
    
    //MARK: - UILabel의 높이를 측정하는 메서드
    func getLabelHeight(tableView: UITableView, text: String) -> CGFloat {
        let label = UILabel(
            frame: .init(
                x: .zero,
                y: .zero,
                width: tableView.frame.width - 75,
                height: .greatestFiniteMagnitude
            )
        )
        label.text = text
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 13)
        label.sizeToFit()
        let labelHeight = label.frame.height
        return labelHeight
    }
    
    func remakeTableView() {
        // 뷰가 나타나고 셀의 크기를 취합하여 테이블 뷰의 레이아웃(높이)를 다시 잡음.
        commentTableView.snp.remakeConstraints { make in
            make.top.equalTo(divisionThickLine.snp.bottom)
            make.leading.equalTo(self.stackView.snp.leading).offset(24)
            make.trailing.equalTo(self.stackView.snp.trailing).offset(-24)
            make.bottom.equalTo(self.stackView.snp.bottom)
            make.height.equalTo(tableViewHeight + 40) // 40은 위ㅔㅇ서 지정한 테이블뷰-헤더뷰 크기임.
        }
    }
    
    func initHeightValue() {
        // 뷰가 나타날 때 해당 값들을 초기화함.
        tableViewHeight = 0.0
        rowHeights = [:]
    }
    
    // UIScrollViewDelegate의 scrollViewDidScroll에 사용
    func imageScrollCount(scrollView: UIScrollView) {
        guard scrollView.frame.width > 0 else {
            return
        }
        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
        print(round(scrollView.contentOffset.x))
        print(scrollView.frame.width)
        self.imagePageCount.text = "\(Int(pageIndex) + 1)/\(self.contentImages.count)"
    }
    
    // UITableView의 heightForRowAt에 사용
    func tableViewCellHeight(indexPath: IndexPath, tableView: UITableView) -> CGFloat {
        if let cachedHeight = rowHeights[indexPath] {
            return cachedHeight
        }
        
        let labelHeight = getLabelHeight(tableView: tableView, text: dummyData[indexPath.row])
        
        // 50 = cell의 commentLabel의 버티컬 패딩 값 조절을 위한 값 / 증가(패딩 증가) / 감소(패딩 감소)
        tableViewHeight += (labelHeight + 50)
        rowHeights[indexPath] = labelHeight + 50
        return labelHeight
    }
    
    // UITextViewDelegate의 textViewDidChange에 사용
    func textViewChange(textView: UITextView) {
        let size = CGSize(width: commentTextView.frame.width, height: .greatestFiniteMagnitude)
        let estimatedSize = textView.sizeThatFits(size)
        
        if textView.text == "" {
            placeHolder.textColor = .white
        } else {
            placeHolder.textColor = .clear
        }
        
        if estimatedSize.height > 102 {
            textView.isScrollEnabled = true
            
            textView.constraints.forEach { constraint in
                if constraint.firstAttribute == .height {
                    constraint.constant = 102
                }
            }
        } else {
            textView.isScrollEnabled = false
            textView.constraints.forEach { constraint in
                if constraint.firstAttribute == .height {
                    constraint.constant = estimatedSize.height
                }
            }
        }
        
        // textView 18 Font 기준
        // 1줄 - 37.6666
        // 2줄 - 59.0
        // 3줄 - 80.6666
        // 4줄 - 102.0
    }
    
    func configureTableView(scrollViewDelegate: UIScrollViewDelegate, tableViewDelegate: UITableViewDelegate, tableViewDatasource: UITableViewDataSource, textViewDelegate: UITextViewDelegate) {
        imageScrollView.delegate = scrollViewDelegate
        
        commentTableView.delegate = tableViewDelegate
        commentTableView.dataSource = tableViewDatasource
        
        commentTextView.delegate = textViewDelegate
    }
    
    
}


extension CommunityDetailView: KeyboardNotificationDelegate {
    func keyboardWillShow(keyboardSize: CGRect) {
        print("keyboard Show")
        
        self.commentBackgroundView.snp.remakeConstraints { make in
            make.width.equalTo(self.frame.width)
            make.height.greaterThanOrEqualTo(40)
            make.leading.trailing.equalTo(self)
            make.bottom.equalTo(self.snp.bottom).offset(-keyboardSize.height)
        }
        
        // 레이아웃 변화를 애니메이션으로 적용
        self.layoutIfNeeded()
    }
    
    func keyboardWillHide(keyboardSize: CGRect) {
        print("keyboardW Hide")
        
        self.commentBackgroundView.snp.remakeConstraints { make in
            make.width.equalTo(self.frame.width)
            make.height.greaterThanOrEqualTo(40)
            make.leading.trailing.equalTo(self)
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
        }
        
        // 레이아웃 변화를 애니메이션으로 적용
        self.layoutIfNeeded()
    }
}
