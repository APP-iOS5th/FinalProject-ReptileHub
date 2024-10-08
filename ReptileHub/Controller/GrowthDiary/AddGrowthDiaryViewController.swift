//
//  AddGrowthDiaryViewController.swift
//  ReptileHub
//
//  Created by 이상민 on 8/27/24.
//

import UIKit
import PhotosUI
import FirebaseAuth

class AddGrowthDiaryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var previousViewController: GrowthDiaryViewController?
    weak var previousDetailVC: DetailGrowthDiaryViewController?
    private let activityIndicator = CustomActivityIndicator()
    private lazy var addGrowthDiaryView = AddGrowthDiaryView()
    private var selectedImageView: UIImageView?
    let editMode: Bool
    var diaryID: String?
    
    init(editMode: Bool){
        self.editMode = editMode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUP()
        setupActivityIndicator()
    }
    
    
    private func setupActivityIndicator() {
           view.addSubview(activityIndicator)
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
    
    func setUP(){
        self.title = "성장일지"
        self.view = addGrowthDiaryView
        self.view.backgroundColor = .white
        
        let action = UIAction{ [weak self] _ in
            self?.datePickerValueChanged()
        }
        addGrowthDiaryView.addAction(action: action)
        addGrowthDiaryView.configureImageViewActions(target: self, action: #selector(imageViewTapped(_:)))
        
        if self.editMode{
            fetchGrowthDiaryData()
        }

        addGrowthDiaryView.buttonTapped = { [weak self] in
            self?.uploadGrowthDiary()
        }
    }
    
    private func uploadGrowthDiary(){
        let result = addGrowthDiaryView.growthDiaryRequestData()
        print("여기는 보내는 거야", result)
        //등록하기 버튼을 클릭하면 해당 버튼은 더이상 사용하지 못하게 비활성화
        let startMessage = editMode ? "수정 중입니다... \n 잠시만 기다려주세요" : "등록 중입니다... \n 잠시만 기다려주세요"
            showActivityIndicator(withMessage: startMessage)


        if editMode{
            //editMode가 true일떄 수정하기 활성화
            guard let diaryID = diaryID else { return }
            DiaryPostService.shared.updateGrowthDiary(userID: UserService.shared.currentUserId, diaryID: diaryID, updatedDiary: result.0, newSelfImageData: result.1[0], newMotherImageData: result.1[1], newFatherImageData: result.1[2]) { [weak self] error in
                
                //해당 요청이 끝나면 다시 버튼 활성화 시켜주기
                defer{
                    self?.addGrowthDiaryView.uploadGrowthDiaryButton.isEnabled = true
                    self?.hideActivityIndicator()
                }
                
                if let error = error{
                    print("ERROR: \(error.localizedDescription)")
                }else{
                    if let previousVC = self?.previousViewController,
                    let previousDetailVC = self?.previousDetailVC{
                        previousVC.updateImage()
                        previousDetailVC.updateDetailDate()
                    }
                    NotificationCenter.default.post(name: .parentInfoShow, object: nil, userInfo: ["parentShow": result.2])
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }else{
            print("등록시작")
           
           
            //editMode가 false일때 등록하기 활성화
            DiaryPostService.shared.registerGrowthDiary(userID: UserService.shared.currentUserId, diary: result.0, selfImageData: result.1[0], motherImageData: result.1[1], fatherImageData: result.1[2]) { [weak self] error in
                
                //해당 요청이 끝나면 다시 버튼 활성화 시켜주기
                defer{
                    self?.addGrowthDiaryView.uploadGrowthDiaryButton.isEnabled = true
                    self?.hideActivityIndicator()
                    print("등록완료")
                }
                
                if let error = error{
                    print("error", error.localizedDescription)
                }else{
                    print("SSFADFSDFS")
                    if let previousVC = self?.previousViewController{
                        previousVC.updateImage()
                    }
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    //MARK: - 수정 일떄는 데이터를 불러와야함
    private func fetchGrowthDiaryData(){
        guard let diaryID = diaryID else { return }
        DiaryPostService.shared.fetchGrowthDiaryDetails(userID: UserService.shared.currentUserId, diaryID: diaryID) { [weak self] response in
            switch response{
            case .success(let responseData):
                self?.addGrowthDiaryView.configureEditGrowthDiary(configureData: responseData)
            case .failure(let error):
                print("ERROR: \(error.localizedDescription)")
            }
        }
    }

    private func datePickerValueChanged(){
        addGrowthDiaryView.updateDateField()
    }
    
    
    @objc private func imageViewTapped(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
        
        guard let tappedImageView = sender.view as? UIImageView else { return }
        
        selectedImageView = tappedImageView
        
        let photoLibrary = PHPhotoLibrary.shared()
        var config = PHPickerConfiguration(photoLibrary: photoLibrary)
        config.filter = .images
        config.selectionLimit = 1
        
        // UIImagePickerController 설정
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
}

extension AddGrowthDiaryViewController: PHPickerViewControllerDelegate{
    // PHPickerViewControllerDelegate 메서드: 이미지가 선택되었을 때 호출됩니다.
       func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
           picker.dismiss(animated: true, completion: nil)
           
           guard let selectedImageView = selectedImageView else { return }
           
           // 첫 번째 선택된 이미지를 가져와 설정
           if let result = results.first {
               result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
                   guard let self = self, let image = object as? UIImage, error == nil else {
                       print("Error loading image: \(String(describing: error))")
                       return
                   }
                   
                   DispatchQueue.main.async {
                       self.addGrowthDiaryView.setImage(image, for: selectedImageView)
                   }
               }
           }
       }
}
