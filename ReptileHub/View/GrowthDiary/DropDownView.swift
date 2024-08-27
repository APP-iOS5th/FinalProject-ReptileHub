//
//  CustomView.swift
//  ReptileHub
//
//  Created by 이상민 on 8/27/24.
//
import UIKit
import SnapKit

class DropDownView: UIView, UITableViewDelegate, UITableViewDataSource {
    private let menus: [String]
    private let title: String
    private var isOpen = false
    
    private var selectedOption: String? {
        didSet {
            titleButton.setTitle(selectedOption ?? title, for: .normal)
        }
    }
    
    //MARK: - 버튼 생성
    private lazy var titleButton: UIButton = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        let image = UIImage(systemName: "chevron.down", withConfiguration: imageConfig)
        
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseForegroundColor = .gray
        config.baseBackgroundColor = UIColor(red: 215/255, green: 215/255, blue: 215/255, alpha: 0.5)
        config.image = image
        config.imagePlacement = .trailing //이미지가 텍스트 오른쪽에 위치하도록 설정
        config.imagePadding = 10 //텍스트와 이미지 사이의 거리
        
        //버튼의 왼쪽 끝에, 이미지를 오른쪽 끝에 위치시키기 위해 contentInsets 사용
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 13, bottom: 0, trailing: 13)
        
        //버튼 스타일 설정
        config.background.strokeColor = UIColor(red: 215/255, green: 215/255, blue: 215/255, alpha: 1)
        config.background.strokeWidth = 1.0
        config.background.cornerRadius = 5.0
        config.attributedTitle?.font = UIFont.systemFont(ofSize: 16)
        
        
        button.configuration = config
        button.contentHorizontalAlignment = .leading
        
        button.addAction(UIAction { [weak self] _ in
            self?.toggleDropdown()
        }, for: .touchUpInside)
        return button
    }()
    
    //MARK: - 테이블 뷰 생성
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.layer.borderWidth = 1.0
        tableView.layer.cornerRadius = 5
        tableView.layer.borderColor = UIColor.lightGray.cgColor
        tableView.isHidden = true
        tableView.backgroundColor = UIColor(red: 215/255, green: 215/255, blue: 215/255, alpha: 1)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private var tableViewHeightConstraint: Constraint?
    
    // MARK: - Initializer
    init(options: [String], title: String) {
        self.menus = options
        self.title = title
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        addSubview(titleButton)
        
        titleButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(45)
        }
    }
    
    // MARK: - Toggle Dropdown
    private func toggleDropdown() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            print("Key window not found")
            return
        }
        
        isOpen.toggle()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        // 아이콘 업데이트를 애니메이션으로 처리
        let newImage = isOpen ? UIImage(systemName: "chevron.up", withConfiguration: imageConfig) : UIImage(systemName: "chevron.down", withConfiguration: imageConfig)
        newImage?.withTintColor(.red, renderingMode: .alwaysOriginal)
        UIView.transition(with: titleButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.titleButton.setImage(newImage, for: .normal)
        }, completion: nil)
        
        if isOpen {
            // tableView를 윈도우에 추가
            window.addSubview(tableView)
            window.bringSubviewToFront(tableView)
            
            tableView.snp.remakeConstraints { make in
                make.top.equalTo(self.snp.bottom).offset(5)
                make.leading.trailing.equalTo(self)
                self.tableViewHeightConstraint = make.height.equalTo(0).constraint
            }
            
            window.layoutIfNeeded()
            
            let newHeight = CGFloat(menus.count * 44)
            tableViewHeightConstraint?.update(offset: newHeight)
            
            tableView.isHidden = false
            
            UIView.animate(withDuration: 0.3) {
                window.layoutIfNeeded()
            }
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.tableViewHeightConstraint?.update(offset: 0)
                window.layoutIfNeeded()
            }, completion: { _ in
                self.tableView.isHidden = true
                self.tableView.removeFromSuperview()
            })
        }
    }
    
    // MARK: - UITableViewDataSource & UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = menus[indexPath.row]
        cell.backgroundColor = UIColor(red: 215/255, green: 215/255, blue: 215/255, alpha: 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedOption = menus[indexPath.row]
        toggleDropdown()
    }
}
