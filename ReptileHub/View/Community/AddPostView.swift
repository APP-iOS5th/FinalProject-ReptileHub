//
//  AddPostView.swift
//  ReptileHub
//
//  Created by 조성빈 on 8/23/24.
//

import UIKit
import SnapKit
import PhotosUI
import Kingfisher

protocol AddPostViewDelegate: AnyObject {
    func didTapPostButton(imageData: [Data], title: String, content: String)
}

class AddPostView: UIView {
    
    weak var delegate: AddPostViewDelegate?
    
    // PhPicker에서 선택한 이미지들
    var selectedImages: [UIImage?] = []
    
    // selectedImages의 데이터화 배열
    var imageData: [Data] = []
    

    // 키보드 탭 제스쳐
    lazy var tapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        tap.cancelsTouchesInView = false // 터치 이벤트를 취소하지 않도록 설정
        return tap
    }()
    
    let keyboardManager = KeyboardManager()
    
    var imagePickerCollectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    let titleTextField: UITextField = UITextField()
    
    let contentTextView: UITextView = UITextView()
    let textViewPlaceholder: UILabel = UILabel()
    
    let postButton: UIButton = UIButton(type: .system)
    
    var picker: PHPickerViewController = PHPickerViewController(configuration: PHPickerConfiguration())
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        // 제스처 적용(슈퍼뷰 클릭시 키보드 내려감)
        self.addGestureRecognizer(tapGesture)
        
        keyboardManager.delegate = self
        keyboardManager.showNoti()
        keyboardManager.hideNoti()
        
        selectedImages.removeAll()
        imageData.removeAll()
        
        setupImagePickerCollectionView()
        setupTitleTextView()
        setupContentTextView()
        setupPostButton()
        
        postButton.isEnabled = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // super view 클릭시 키보드 내려감
    @objc
    func tapHandler(_ sender: UIView) {
        titleTextField.resignFirstResponder()
        contentTextView.resignFirstResponder()
    }
    
    //MARK: - 이미지피커 콜렉션뷰 setup
    private func setupImagePickerCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: 90, height: 90)
        
        imagePickerCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        imagePickerCollectionView.register(PHPickerCollectionViewCell.self, forCellWithReuseIdentifier: "PHPickerCell")
        imagePickerCollectionView.showsHorizontalScrollIndicator = false
        imagePickerCollectionView.backgroundColor = .white
        self.addSubview(imagePickerCollectionView)
        
        imagePickerCollectionView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.equalTo(self.snp.leading).offset(24)
            make.trailing.equalTo(self.snp.trailing)
            make.height.equalTo(90)
        }
    }
    
    //MARK: - title Textfield setup
    private func setupTitleTextView() {
        titleTextField.placeholder = "제목을 입력해주세요"
        titleTextField.borderStyle = .roundedRect
        titleTextField.textColor = .black
        titleTextField.backgroundColor = .imagePicker
        self.addSubview(titleTextField)
        
        titleTextField.attributedPlaceholder = NSAttributedString(
                string: "제목을 입력해주세요",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.textFieldPlaceholder] // 원하는 색상으로 변경
            )
        
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(imagePickerCollectionView.snp.bottom).offset(15)
            make.leading.equalTo(imagePickerCollectionView.snp.leading)
            make.trailing.equalTo(self.snp.trailing).offset(-24)
            make.height.equalTo(40)
        }
    }
    
    
    //MARK: - content TextView setup
    private func setupContentTextView() {
        contentTextView.backgroundColor = .imagePicker
        contentTextView.layer.cornerRadius = 5
        contentTextView.font = UIFont.systemFont(ofSize: 17)
        contentTextView.textColor = .black
        textViewPlaceholder.text = "내용을 입력해주세요"
        textViewPlaceholder.font = UIFont.systemFont(ofSize: 17, weight: .light)
        textViewPlaceholder.textColor = .textFieldPlaceholder
        
        self.addSubview(contentTextView)
        
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(25)
            make.leading.equalTo(titleTextField.snp.leading)
            make.trailing.equalTo(self.snp.trailing).offset(-24)
            make.height.greaterThanOrEqualTo(200)
        }
        
        self.addSubview(textViewPlaceholder)
        
        textViewPlaceholder.snp.makeConstraints { make in
            make.top.equalTo(contentTextView.snp.top).offset(8)
            make.leading.equalTo(contentTextView.snp.leading).offset(8)
        }
        
    }
    
    
    //MARK: - postButton setup
    private func setupPostButton() {
        postButton.setTitle("등록하기", for: .normal)
        postButton.backgroundColor = .addBtnGraphTabbar
        postButton.setTitleColor(.white, for: .normal)
        postButton.layer.cornerRadius = 5
        postButton.addTarget(self, action: #selector(postButtonAction), for: .touchUpInside)
        
        self.addSubview(postButton)
        
        postButton.snp.makeConstraints { make in
            make.top.equalTo(contentTextView.snp.bottom).offset(25)
            make.leading.equalTo(contentTextView.snp.leading)
            make.trailing.equalTo(contentTextView.snp.trailing)
            make.height.equalTo(50)
        }
    }
    
    @objc
    private func postButtonAction() {
        // 버튼 비활성화
            postButton.isEnabled = false
            
            // 비활성화된 상태에서 배경 색상을 회색으로 변경
            postButton.backgroundColor = UIColor.gray
            
            // 버튼의 텍스트 색상도 적절히 변경할 수 있음
            postButton.setTitleColor(.lightGray, for: .normal)
        delegate?.didTapPostButton(imageData: imageData, title: titleTextField.text ?? "nil", content: contentTextView.text ?? "nil")
    }
    
    func configureAddPostView(delegate: UICollectionViewDelegate, datasource: UICollectionViewDataSource, textViewDelegate: UITextViewDelegate) {
        imagePickerCollectionView.delegate = delegate
        imagePickerCollectionView.dataSource = datasource
        contentTextView.delegate = textViewDelegate
    }
    
    func createPHPickerVC() -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 5
        config.filter = .images
        
        return PHPickerViewController(configuration: config)
        
    }
    
    func configureEdit(configureEditData: PostDetailResponse) {
        print("수정이다 수정!! : \(configureEditData)")
            var images = [UIImage]()
            for image in configureEditData.imageURLs {
                let uiImage = UIImage()
                KingfisherManager.shared.retrieveImage(with: URL(string: image)!) { result in
                    
                    switch result {
                        case .success(let value):
                            // 성공적으로 이미지를 다운로드했을 때
                            let image = value.image
                            print("Image downloaded: (image)")

                            self.selectedImages.append(image)
                        self.imagePickerCollectionView.reloadData()
                        case .failure(let error):
                            // 에러 처리
                            print("Error downloading image: (error)")
                        }
                    }
            }
            titleTextField.text = configureEditData.title
            contentTextView.text = configureEditData.content
            textViewPlaceholder.isHidden = true
        postButton.setTitle("수정하기", for: .normal)
        }
    
}




extension AddPostView: KeyboardNotificationDelegate {
    func keyboardWillShow(keyboardSize: CGRect) {
        print("keyboard Show")
        
        if isTextViewFirstResponder() {
            self.imagePickerCollectionView.snp.remakeConstraints { make in
                make.top.equalTo(self.snp.top)
                make.leading.equalTo(self.snp.leading).offset(24)
                make.trailing.equalTo(self.snp.trailing)
                make.height.equalTo(90)
            }
            
            // 레이아웃 변화를 애니메이션으로 적용
            self.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide(keyboardSize: CGRect) {
        print("keyboardW Hide")
        
        if isTextViewFirstResponder() {
            self.imagePickerCollectionView.snp.remakeConstraints { make in
                make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(10)
                make.leading.equalTo(self.snp.leading).offset(24)
                make.trailing.equalTo(self.snp.trailing)
                make.height.equalTo(90)
            }
            
            // 레이아웃 변화를 애니메이션으로 적용
            self.layoutIfNeeded()
        }
    }
    
    private func isTextViewFirstResponder() -> Bool {
        // 모든 서브뷰를 검색해서 UITextView가 첫 번째 응답자인지 확인함
        for subview in self.subviews {
            if let textView = subview as? UITextView, textView.isFirstResponder {
                return true
            }
        }
        return false
    }
}

