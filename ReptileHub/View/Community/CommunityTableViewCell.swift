//
//  CommunityTableViewCell.swift
//  ReptileHub
//
//  Created by 조성빈 on 8/8/24.
//

import UIKit
import SnapKit
import Kingfisher

let imageCache = NSCache<NSString, UIImage>()

class CommunityTableViewCell: UITableViewCell {
    
    var testUserProfile: UserProfile? {
        didSet {
            guard let testUserProfile = testUserProfile else { return }
            self.nicknameLabel.text = testUserProfile.name
        }
    }
    
    lazy var thumbnailImageView: UIImageView = UIImageView()
    
    lazy var titleLabel: UILabel = UILabel()
    private let contentLabel: UILabel = UILabel()
    private let mainInfoStackView: UIStackView = UIStackView()
    
    private let commentIcon: UIImageView = UIImageView()
    private let commentCountLabel: UILabel = UILabel()
    private let bookmarkIcon: UIImageView = UIImageView()
    private let bookmarkCountLabel: UILabel = UILabel()
    private let firstStackView: UIStackView = UIStackView()
    
    private let nicknameLabel: UILabel = UILabel()
    private let timestampLabel: UILabel = UILabel()
    private let secondStackView: UIStackView = UIStackView()
    
    private let menuButton: UIButton = UIButton()
    
    
    //    override func awakeFromNib() {
    //        super.awakeFromNib()
    //    }
    //
    //    override func setSelected(_ selected: Bool, animated: Bool) {
    //        super.setSelected(selected, animated: animated)
    //    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupThumbnail()
        setupMenuButton()
        setupMainInfoStackView()
        setupSubInfoStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Thumnail Image
    private func setupThumbnail() {
        thumbnailImageView.image = UIImage(systemName: "camera")
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.layer.cornerRadius = 5
        thumbnailImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        thumbnailImageView.backgroundColor = .lightGray
        
        self.contentView.addSubview(thumbnailImageView)
        
        thumbnailImageView.snp.makeConstraints { make in
            make.height.width.equalTo(85)
            make.centerY.equalToSuperview()
//            make.top.equalTo(self.contentView.snp.top).offset(10)
//            make.bottom.equalTo(self.contentView.snp.bottom).offset(-10)
            make.leading.equalTo(self.contentView.snp.leading).offset(12)
        }
    }
    
    //MARK: - 제목, 내용 StackView
    private func setupMainInfoStackView() {
        mainInfoStackView.axis = .vertical
        mainInfoStackView.distribution = .fill
        mainInfoStackView.alignment = .leading
        
        titleLabel.text = "Title"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        contentLabel.text = "Content"
        contentLabel.numberOfLines = 0
        contentLabel.font = UIFont.systemFont(ofSize: 15, weight: .light)
        
        self.contentView.addSubview(mainInfoStackView)
        
        mainInfoStackView.snp.makeConstraints { make in
            make.top.equalTo(thumbnailImageView.snp.top)
            make.leading.equalTo(thumbnailImageView.snp.trailing).offset(7)
//            make.bottom.equalTo(firstStackView.snp.top)
            make.trailing.equalTo(menuButton.snp.leading)
            make.height.greaterThanOrEqualTo(55)
        }
        
        mainInfoStackView.addArrangedSubview(titleLabel)
        mainInfoStackView.addArrangedSubview(contentLabel)
        
        contentLabel.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(30)
            make.top.equalTo(titleLabel.snp.bottom)
        }
    }
    
    //MARK: - 댓글, 좋아요 수, 닉네임, 게시날짜 stackview
    private func setupSubInfoStackView() {
        // 댓글, 좋아요 이미지와 count 스택뷰
        firstStackView.axis = .horizontal
        firstStackView.distribution = .equalSpacing
        firstStackView.alignment = .center
        firstStackView.spacing = 5
        
        commentCountLabel.text = "9999"
        commentCountLabel.font = UIFont.systemFont(ofSize: 13, weight: .light)
        bookmarkCountLabel.text = "9999"
        bookmarkCountLabel.font = UIFont.systemFont(ofSize: 13, weight: .light)
        
        
        let commentImageConfig = UIImage.SymbolConfiguration(pointSize: 13, weight: .light)
        let heartImageConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .light)
        commentIcon.image = UIImage(systemName: "message", withConfiguration: commentImageConfig)
        bookmarkIcon.image = UIImage(systemName: "heart", withConfiguration: heartImageConfig)
        

        firstStackView.addArrangedSubview(commentIcon)
        firstStackView.addArrangedSubview(commentCountLabel)
        firstStackView.addArrangedSubview(bookmarkIcon)
        firstStackView.addArrangedSubview(bookmarkCountLabel)
        
        // 닉네임, 게시날짜 스택뷰
        secondStackView.axis = .horizontal
        secondStackView.distribution = .equalSpacing
        secondStackView.alignment = .center
        secondStackView.spacing = 10
        
        nicknameLabel.text = testUserProfile?.name ?? "구현현서"
        nicknameLabel.font = UIFont.systemFont(ofSize: 13, weight: .ultraLight)
        timestampLabel.text = "24.08.05 17:00"
        timestampLabel.font = UIFont.systemFont(ofSize: 13, weight: .ultraLight)
        
        secondStackView.addArrangedSubview(nicknameLabel)
        secondStackView.addArrangedSubview(timestampLabel)
        
        // 오토레이아웃
        self.contentView.addSubview(firstStackView)
        self.contentView.addSubview(secondStackView)
        
        firstStackView.snp.makeConstraints { make in
            make.leading.equalTo(thumbnailImageView.snp.trailing).offset(5)
            make.top.equalTo(mainInfoStackView.snp.bottom)
            make.bottom.equalTo(thumbnailImageView.snp.bottom)
            make.height.equalTo(20)
        }
        
        secondStackView.snp.makeConstraints { make in
            make.trailing.equalTo(menuButton.snp.centerX)
            make.bottom.equalTo(firstStackView)
        }
    }
    
    //MARK: - menu 버튼
    private func setupMenuButton() {
        menuButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        menuButton.contentMode = .scaleAspectFit
        menuButton.transform = CGAffineTransform(rotationAngle: .pi * 0.5)
        
        self.contentView.addSubview(menuButton)
        
        menuButton.snp.makeConstraints { make in
            make.top.equalTo(self.contentView).offset(5)
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-5)
            
        }
    }
    
    func configure(imageName: String, title: String, content: String, createAt: String, commentCount: Int, likeCount: Int) {

        thumbnailImageView.setImage(with: imageName)
        
        titleLabel.text = title
        contentLabel.text = content
        timestampLabel.text = createAt
        commentCountLabel.text = "\(commentCount)"
        bookmarkCountLabel.text = "\(likeCount)"
    }
    
}

extension UIImageView {
    func loadImage(from urlString: String, retryCount: Int = 3) {
        
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            print("이미지 캐시에서 로드: \(urlString)")
            self.image = cachedImage
            return
        }

        guard let url = URL(string: urlString) else {
            print("잘못된 URL: \(urlString)")
            return
        }
        
        print("URL 세션으로 이미지 다운로드 시작: \(urlString)")
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("이미지 다운로드 실패: \(error.localizedDescription)")
                
                // 네트워크 연결이 중단되었을 때 재시도
                if retryCount > 0 {
                    print("재시도 남은 횟수: \(retryCount), 다시 시도 중...")
                    self?.loadImage(from: urlString, retryCount: retryCount - 1)
                } else {
                    print("재시도 횟수를 초과하여 이미지 로드를 포기합니다.")
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("서버 응답 오류: \(String(describing: response))")
                return
            }
            
            guard let data = data else {
                print("이미지 데이터가 없음")
                return
            }
            
            guard let image = UIImage(data: data) else {
                print("데이터를 이미지로 변환할 수 없음")
                return
            }
            
            imageCache.setObject(image, forKey: urlString as NSString)
            
            DispatchQueue.main.async {
                print("이미지 UI 업데이트: \(urlString)")
                self?.image = image
            }
        }.resume()
    }
}

extension UIImageView {
  func setImage(with urlString: String) {
    ImageCache.default.retrieveImage(forKey: urlString, options: nil) { result in
      switch result {
      case .success(let value):
        if let image = value.image {
          //캐시가 존재하는 경우
          self.image = image
        } else {
          //캐시가 존재하지 않는 경우
          guard let url = URL(string: urlString) else { return }
            let resource = KF.ImageResource(downloadURL: url, cacheKey: urlString)
          self.kf.setImage(with: resource)
        }
      case .failure(let error):
        print(error)
      }
    }
  }
}
