//
//  UIDatePickerExtension.swift
//  ReptileHub
//
//  Created by 이상민 on 8/28/24.
//

import UIKit
import Kingfisher

//MARK: - 0000.00.00 형식으로 날짜추출
extension Date{
    var formatted: String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy. MM. dd"
        return formatter.string(from: self)
    }
}

//MARK: - Kingfisher을 이용한 url 이미지 불러오기 함수
// TODO: 캐시에 저장해서 사용하는 방식으로 코드로 구현했으므로 추후에 삭제하거나, 수정할 때 캐시를 삭제해주는 코드도 구현해야 한다.
// 캐시에서 해당 이미지 삭제
//ImageCache.default.removeImage(forKey: urlString) {
//    print("Image removed from cache successfully")
//}
extension UIImageView{
    //배열로도 받아올 수 있게하기
    func setImage(with urlString: String) {
        ImageCache.default.retrieveImage(forKey: urlString, options: nil) { result in
            
            //로딩 스피너 추가
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
            spinner.startAnimating()
            self.addSubview(spinner)
            
            switch result {
            case .success(let value):
                if let image = value.image {
                    //캐시가 존재하는 경우
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                        self.image = image
                        spinner.stopAnimating()
                        spinner.removeFromSuperview()
                    }
                    
                } else {
                    //캐시가 존재하지 않는 경우
                    guard let url = URL(string: urlString) else {
                        spinner.stopAnimating()
                        spinner.removeFromSuperview()
                        return
                    }
                    let resource = KF.ImageResource(downloadURL: url, cacheKey: urlString)
                    self.kf.setImage(with: resource) { result in
                        //이미지 로딩이 완료되면 스피너 제거
                        spinner.stopAnimating()
                        spinner.removeFromSuperview()
                    }
                }
            case .failure(let error):
                print(error)
                spinner.stopAnimating()
                spinner.stopAnimating()
            }
        }
    }
}
