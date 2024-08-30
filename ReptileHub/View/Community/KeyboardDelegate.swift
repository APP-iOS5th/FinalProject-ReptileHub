//
//  KeyboardProtocol.swift
//  ReptileHub
//
//  Created by 조성빈 on 8/25/24.
//

import Foundation
import UIKit


protocol KeyboardNotificationDelegate: AnyObject {
    //================================================//
    func keyboardWillShow(keyboardSize: CGRect)
    func keyboardWillHide(keyboardSize: CGRect)
    // keyboardAction() 내부에서 키보드가 올라올 때, 내려갈 때의 레이아웃 들을 정의해주시면 됩니다! (extension으로)
    // 애니메이션을 적용해야해서 위 두가지의 메서드를 정의하고 마지막에 self.layoutIfNeeded() 를 넣어주세요!
    // (self.layoutIfNeeded()는 UIView에서만 사용할 수 있어서 따로 불러오셔야합니다..)
    //================================================//
}

class KeyboardManager {
    
    //================================================//
    // 델리게이트 변수
    weak var delegate: KeyboardNotificationDelegate?
    
    
    // 키보드 나옴/숨김 NotificationCenter
    func showNoti() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardAction),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func hideNoti() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardAction),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    // delgate, showNoti(), hideNoti() 이 세 가지는 viewDidLoad() 내부에 있어야합니다~
    //================================================//
    
    //================================================//
    // 키보드가 올라옴에 따라 뷰를 움직이는 것이기 때문에 ViewController가 아닌 View에 extension으로
    // 원하는 레이아웃을 잡아주시면 됩니다~!
    @objc
    private func keyboardAction(_ notification: NSNotification) {
        guard let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let animationCurveRawNSN = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber else {
            return
        }
        
        let animationCurveRaw = animationCurveRawNSN.uintValue
        let animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw)
        
        switch notification.name {
        case UIResponder.keyboardWillShowNotification:
            print("키보드 열림")
            
            UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurve, animations: {
                        
                // 델리게이트를 통해 메서드 호출
                self.delegate?.keyboardWillShow(keyboardSize: keyboardSize)
    
                    }, completion: nil)
            

            
        case UIResponder.keyboardWillHideNotification:
            print("키보드 닫힘")
            
            UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurve, animations: {
                        
                // 델리게이트를 통해 메서드 호출
                self.delegate?.keyboardWillHide(keyboardSize: keyboardSize)
                
                    }, completion: nil)
            
        default:
            return
        }
    }
    //================================================//
}
