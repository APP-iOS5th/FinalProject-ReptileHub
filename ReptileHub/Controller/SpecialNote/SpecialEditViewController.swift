//
//  SpecialEditViewController.swift
//  ReptileHub
//
//  Created by 황민경 on 8/21/24.
//

import UIKit
import SnapKit
import PhotosUI
import FirebaseAuth

class SpecialEditViewController: UIViewController {
    
    private let specialEditView = SpecialEditView()
    private let activityIndicator = CustomActivityIndicator()
    var diaryID: String
    
    var editMode: Bool
    
    var editEntry: DiaryResponse?
    
    var originalImageURLs: [String] = []
    
    var removedImageURLs: [String] = []
    
    weak var previousVC: SpecialListViewController? //SpecialListVC 받는 변수
    
    weak var previousDetailVC: SpecialDetailViewController? //SpecialDetailVC 받는 변수
    
    init(diaryID: String, editMode: Bool) {
        self.diaryID = diaryID
        self.editMode = editMode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // editMode: 수정 모드
    override func viewIsAppearing(_ animated: Bool) {
        if editMode {
            if let editEntry = self.editEntry {
                originalImageURLs = editEntry.imageURLs
                specialEditView.configureEdit(configureEditData: editEntry)
            }
        }
    }
    func fetchEditData() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupActivityIndicator()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = specialEditView
        specialEditView.configureSpecialEditView(delegate: self, datasource: self, textViewDelegate: self)
        specialEditView.delegate = self
        navigationItem.title = "특이사항"
        // Do any additional setup after loading the view.
    }
   
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
//        activityIndicator.backgroundColor = .red
        activityIndicator.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.equalTo(300)
            $0.height.equalTo(400)
            
        }
           activityIndicator.isHidden = true
       }
    func showActivityIndicator(withMessage message: String) {
           DispatchQueue.main.async { [weak self] in
               self?.activityIndicator.isHidden = false
               self?.activityIndicator.startAnimating(withMessage: message)
           }
       }

       func hideActivityIndicator() {
           DispatchQueue.main.async { [weak self] in
               self?.activityIndicator.stopAnimating()
               self?.activityIndicator.isHidden = true
           }
       }


}
//MARK: - SpecialEditView Image CollectionViewDelegate 관련
extension SpecialEditViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return specialEditView.selectedImages.count + 1 // 첫 셀은 PH피커이므로 + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PHPickerCell", for: indexPath) as! SpecialPHPickerCollectionViewCell
        
        if indexPath.item == 0 {
            let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .light)
            let cameraImage = UIImage(systemName: "camera", withConfiguration: config)
            cell.imageView.image = cameraImage
            cell.imageView.contentMode = .center
            cell.deleteButton.isHidden = true
        } else {
            cell.imageView.image = specialEditView.selectedImages[indexPath.item - 1]
            cell.imageView.contentMode = .scaleAspectFill
            cell.delegate = self
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            let picker = specialEditView.createPHPickerVC()
            picker.delegate = self
            present(picker, animated: true, completion: nil)
        }
    }
}
//MARK: - SpecialEditView Image PHPickerCollectionViewDelegate 관련
extension SpecialEditViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        print("사진 선택완료~")
        picker.dismiss(animated: true, completion: nil)
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                guard let self = self else { return }
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        // 피커에서 추가로 이미지 선택할 경우 이미지 배열에 추가해서 선택한 사진 바로 리로드
                        if self.specialEditView.selectedImages.count < 5{
                            self.specialEditView.selectedImages.append(image)
                            self.specialEditView.imagePickerCollectionView.reloadData()
                            
                            if let imageData = image.jpegData(compressionQuality: 0.8) {
                                self.specialEditView.imageData.append(imageData)
                            }
                            
                        } else {
                            print("이미 선택된 이미지가 5개 입니다.")
                            return
                        }
                    }
                }
            }
        }
    }
    
}
//MARK: - SpecialEditView Image PHPickerCollectionViewCellDelegate 관련
extension SpecialEditViewController: SpecialPHPickerCollectionViewCellDelegate {
    // Image CollectionView 삭제 버튼 관련
    func didTapDeleteButton(indexPath: IndexPath) {
        // 이미지 배열 첫번째는 선택 버튼이라 빼준다.
        let index = indexPath.item - 1
        // 삭제할 이미지의 인덱스가 선택된 이미지들의 개수보다 작다면
        if index < specialEditView.selectedImages.count {
            // 만약 삭제할 이미지가 기존의 이미지라면
            if index < originalImageURLs.count {
                // 삭제할 이미지URL을 변수에 저장
                let removedImageURL = originalImageURLs[index]
                removedImageURLs.append(removedImageURL) // 삭제해야될 url 들을 배열에 저장해서 관리
                originalImageURLs.remove(at:index) // 기존 이미지 URL에서 제거
            } else {
                let newImageIndex = index - originalImageURLs.count
                // 새로운 이미지의 경우, ImagesData에서 제거 - 기존 이미지 뒤에 새로 선택한 사진이 나옴(imageData)
                specialEditView.imageData.remove(at: newImageIndex)
            }
            // 선택된 배열 목록에서 해당 인덱스 제거
            specialEditView.selectedImages.remove(at: index)
            specialEditView.imagePickerCollectionView.reloadData()
        }
    }
    
}

//MARK: -  textview placeholder
extension SpecialEditViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == "" {
            self.specialEditView.textViewPlaceholder.isHidden = false
        } else {
            self.specialEditView.textViewPlaceholder.isHidden = true
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = ""
        }
    }
}
//MARK: - SpecialEidtView 데이터 저장해서 게시
extension SpecialEditViewController: SpecialEditViewDelegate {
    func didTapPostButton(imageData: [Data], date: Date, title: String, text: String, targetButton: UIButton) {
        
        //버튼을 누르자마자 해당 버튼 비활성화
        targetButton.isEnabled = false
        targetButton.backgroundColor = .imagePicker
        let startMessage = editMode ? "수정 중입니다... \n 잠시만 기다려주세요" : "등록 중입니다... \n 잠시만 기다려주세요"
            showActivityIndicator(withMessage: startMessage)

     
        
        if editMode { // SpecialEditView 수정 모드일 때
            guard let editEntry = self.editEntry else { return }
            DiaryPostService.shared.updateDiary(userID: UserService.shared.currentUserId, diaryID: diaryID, entryID: editEntry.entryID, newTitle: title, newContent: text, newImages: imageData, existingImageURLs: originalImageURLs, removedImageURLs: removedImageURLs, newSelectedDate: date) { [weak self] error in
                
                //요청으로 부터 어떤 응답이 오면 버튼을 다시 활성화 시켜준다
                defer{
                    targetButton.isEnabled = true
                    targetButton.backgroundColor = UIColor.addBtnGraphTabbar
                    self?.hideActivityIndicator()
                }
                
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("업데이트 완료")
                    if let previousDetailVC = self?.previousDetailVC {
                        previousDetailVC.updateSpecialData()
                    }
                    if let previousVC = self?.previousVC {
                        previousVC.updateSpecialData()
                    }
                    self?.navigationController?.popViewController(animated: true)
                } 
            }
        }
        else { // SpecialEditView 등록 모드일 때
           
            print("""
                    [현재 등록할 게시글 내용]
                    imageData: \(imageData)
                    date: \(date)
                    title: \(title)
                    text: \(text)
                    """)
            DiaryPostService.shared.createDiary(userID: UserService.shared.currentUserId, diaryID: diaryID, images: imageData, title: title, content: text, selectedDate: date){ [weak self]
                error in
                
                //요청으로 부터 어떤 응답이 오면 버튼을 다시 활성화 시켜준다
                defer{
                    targetButton.isEnabled = true
                    targetButton.backgroundColor = UIColor.addBtnGraphTabbar
                    self?.hideActivityIndicator()
                }
                    if let error = error {
                                print("게시글 게시 중 오류 발생: \(error.localizedDescription)")
                            } else {
                                print("게시글 게시 성공")
                                if let previousVC = self?.previousVC {
                                    previousVC.updateSpecialData()
                                    print("EditView previousVC", previousVC)
                                }
                                self?.navigationController?.popViewController(animated: true)
                            }
            }
        }
    }
    
    
}
