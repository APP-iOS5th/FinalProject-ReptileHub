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
    var isOpen = false
    
    private(set) var selectedOption: String? {
        didSet {
            titleButton.setTitle(selectedOption ?? title, for: .normal)
        }
    }
    
    private lazy var titleButton: UIButton = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        let image = UIImage(systemName: "chevron.down", withConfiguration: imageConfig)
        
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseForegroundColor = .gray
        config.baseBackgroundColor = UIColor(red: 215/255, green: 215/255, blue: 215/255, alpha: 0.5)
        config.image = image
        config.imagePlacement = .trailing
        config.imagePadding = 10
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 13, bottom: 0, trailing: 13)
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
    private var isDropdownUpward = false
    
    init(options: [String], title: String) {
        self.menus = options
        self.title = title
        super.init(frame: .zero)
        setupUI()
        registerForNotifications()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(titleButton)
        
        titleButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(45)
        }
    }
    
    private func toggleDropdown() {
        if isOpen {
            closeDropdown()
        } else {
            openDropdown()
        }
    }
    
    private func openDropdown() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            print("Key window not found")
            return
        }
        
        NotificationCenter.default.post(name: .dropdownDidOpen, object: self)
        isOpen = true
        updateButtonIcon()
        
        window.addSubview(tableView)
        window.bringSubviewToFront(tableView)
        
        let dropdownHeight = CGFloat(menus.count * 45)
        let availableHeightBelow = calculateAvailableHeightBelow()
        let availableHeightAbove = calculateAvailableHeightAbove()
        let tabBarHeight: CGFloat = 49 // 일반적으로 탭바의 높이
        let extraSpacing: CGFloat = 50 // 여유 공간 설정
        
        var targetHeight: CGFloat
        if availableHeightBelow < dropdownHeight + tabBarHeight + extraSpacing {
            // 위로 펼쳐질 경우
            targetHeight = min(dropdownHeight, availableHeightAbove)
            isDropdownUpward = true
            tableView.snp.remakeConstraints { make in
                make.bottom.equalTo(self.snp.top).offset(-5)
                make.leading.trailing.equalTo(self)
                self.tableViewHeightConstraint = make.height.equalTo(0).constraint
            }
        } else {
            // 아래로 펼쳐질 경우
            targetHeight = dropdownHeight
            isDropdownUpward = false
            tableView.snp.remakeConstraints { make in
                make.top.equalTo(self.snp.bottom).offset(5)
                make.leading.trailing.equalTo(self)
                self.tableViewHeightConstraint = make.height.equalTo(0).constraint
            }
        }
        
        window.layoutIfNeeded()
        
        tableView.isHidden = false
        
        UIView.animate(withDuration: 0.1) {
            self.tableViewHeightConstraint?.update(offset: targetHeight)
            window.layoutIfNeeded()
        }
    }
    
    
    private func calculateAvailableHeightBelow() -> CGFloat {
        guard let window = window else { return 0 }
        let dropdownY = self.convert(self.bounds.origin, to: window).y + self.bounds.height
        return window.bounds.height - dropdownY
    }
    
    private func calculateAvailableHeightAbove() -> CGFloat {
        guard let window = window else { return 0 }
        let dropdownY = self.convert(self.bounds.origin, to: window).y
        return dropdownY
    }
    
    
    private func updateButtonIcon() {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        let newImage = isOpen ? UIImage(systemName: "chevron.up", withConfiguration: imageConfig) : UIImage(systemName: "chevron.down", withConfiguration: imageConfig)
        
        UIView.transition(with: titleButton, duration: 0.1, options: .transitionCrossDissolve, animations: {
            self.titleButton.setImage(newImage, for: .normal)
        }, completion: nil)
    }
    
    @objc func closeDropdownOnScroll() {
        if isOpen {
            closeDropdown()
        }
    }
    
    @objc func closeDropdown(){
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            print("Key window not found")
            return
        }
        
        guard isOpen else { return }
        isOpen = false
        
        updateButtonIcon()
        
        UIView.animate(withDuration: 0.1, animations: {
            self.tableViewHeightConstraint?.update(offset: 0)
            window.layoutIfNeeded()
        }, completion: { _ in
            self.tableView.isHidden = true
            self.tableView.removeFromSuperview()
        })
    }
    
    private func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleDropdownDidOpen(_:)), name: .dropdownDidOpen, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(closeDropdown), name: UITextField.textDidBeginEditingNotification, object: nil)
    }
    
    @objc private func handleDropdownDidOpen(_ notification: Notification) {
        if let sender = notification.object as? DropDownView, sender !== self {
            closeDropdown()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        closeDropdown()
    }
}

extension Notification.Name {
    static let dropdownDidOpen = Notification.Name("dropdownDidOpen")
}
