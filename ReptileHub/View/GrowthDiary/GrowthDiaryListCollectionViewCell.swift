//
//  GrowthDiaryListCollectionViewCell.swift
//  ReptileHub
//
//  Created by 이상민 on 8/13/24.
//

import UIKit
import SnapKit
import Kingfisher

let imageCache = NSCache<NSString, UIImage>()

class GrowthDiaryListCollectionViewCell: UICollectionViewCell {


    static let identifier = "GrowthDiaryListCell"
    
    private lazy var GrowthDiaryItemImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var GrowthDiaryItemTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    private lazy var GrowthDiaryItemDate: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
    
    private func setUp(){
        contentView.addSubview(GrowthDiaryItemImage)
        contentView.addSubview(GrowthDiaryItemTitle)
        contentView.addSubview(GrowthDiaryItemDate)
        
        GrowthDiaryItemImage.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(contentView)
            make.height.equalTo(GrowthDiaryItemImage.snp.width).multipliedBy(0.74)
        }
        
        GrowthDiaryItemTitle.snp.makeConstraints { make in
            make.top.equalTo(GrowthDiaryItemImage.snp.bottom).offset(10)
            make.leading.trailing.equalTo(contentView)
        }
        
        GrowthDiaryItemDate.snp.makeConstraints { make in
            make.leading.trailing.equalTo(contentView)
            make.top.equalTo(GrowthDiaryItemTitle.snp.bottom).offset(3)
            make.bottom.equalToSuperview()
        }
    }
    
    
    
    func configure(imageName: String, title: String, date: String){
        if let url = URL(string: imageName){
//            GrowthDiaryItemImage.kf.setImage(with: url,
//                                             placeholder: nil,
//                                             options: [.transition(.fade(1.2))],
//                                             completionHandler: nil)
            GrowthDiaryItemImage.setImage(with: imageName)
        }
        GrowthDiaryItemTitle.text = title
        GrowthDiaryItemDate.text = date
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
          let resource = ImageResource(downloadURL: url, cacheKey: urlString)
          self.kf.setImage(with: resource)
        }
      case .failure(let error):
        print(error)
      }
    }
  }
}
