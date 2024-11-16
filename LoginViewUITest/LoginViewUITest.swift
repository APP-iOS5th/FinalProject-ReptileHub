//
//  LoginViewUITest.swift
//  LoginViewUITest
//
//  Created by 임재현 on 11/14/24.
//

import XCTest
import ReptileHub

final class LoginViewUITest: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        self.continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UITesting"]
        app.launch()
        
    }

    override func tearDownWithError() throws {
  
    }
    
    func test_UI요소들이제대로있는지확인() throws {
        //Given
        let logoImage = app.images["LoginView.logoImage"]
        let lineView = app.otherElements["LoginView.lineView"]
        let stackView = app.otherElements["LoiginVIew.stackView"]
        
        //Then
        XCTAssertTrue(logoImage.exists, "로고 이미지 존재 확인")
        XCTAssertTrue(lineView, "lineView 존재 확인")
        XCTAssertTrue(stackView, "stackView 존재 확인")

    }
    
    func test_모든소셜로그인버튼이제대로있는지확인() {
        //Given
        let kakaoButton = app.buttons["LoginView.kakaoButton"]
        let googleButton = app.buttons["LoginView.googleButton"]
        let appleButton = app.buttons["LoginView.appleButton"]
        
        //Then
        XCTAssertTrue(kakaoButton.exists, "카카오버튼 존재 확인")
        XCTAssertTrue(googleButton.exists, "구글버튼 존재 확인")
        XCTAssertTrue(appleButton.exists, "애플버튼 존재 확인")
        
    }
    
    func test_레이아웃제약확인() {
        //Given
        let logoImage = app.images["LoginView.logoImage"]
        let lineView = app.otherElements["LoginView.lineView"]
        let stackView = app.otherElements["LoginView.stackView"]
        
        //Then
        
        // 로고 이미지가 상단에 위치하는지 확인
        XCTAssertLessThan(logoImage.frame.maxY, logoImage.frame.minY)
        // 라인뷰가 로고-스택뷰 사이에 위치하고 있는지 확인
        XCTAssertLessThan(lineView.frame.maxY, stackView.frame.minY)
        // 스택뷰 안에 소셜 로그인버튼 3개가 잘 들어있는지 확인
        XCTAssertTrue(stackView.buttons.count == 3, "스택뷰 안에 버튼 3개 확인")
    }
    
    func test_버튼사이즈제약확인() {
        //Given
        let buttons = [
            app.buttons["LoginView.kakaoButton"],
            app.buttons["LoginView.googleButton"],
            app.buttons["LoginView.appleButton"]
        ]
        
        //Then
        buttons.forEach { button in
            let frame = button.frame
            XCTAssertEqual(frame.width, CGFloat(344), accuracy: 1.0)
            XCTAssertEqual(frame.height, CGFloat(52), accuracy: 1.0)
        }
    }
    
    func test_버튼클릭이벤트구독확인() {
        //Given
        let buttons = [
            app.buttons["LoginView.kakaoButton"],
            app.buttons["LoginView.googleButton"],
            app.buttons["LoginView.appleButton"]
        ]
        
        buttons.forEach { button in
            XCTAssertTrue(button.isEnabled, "버튼 클릭 가능 확인")
            button.tap()
        }
    }


    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
