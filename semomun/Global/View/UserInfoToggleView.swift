//
//  UserInfoToggleView.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/18.
//

import UIKit

protocol UserInfoPushable: AnyObject {
    func showUserSetting()
    func showSetting()
    func showLoginVC()
}

final class UserInfoToggleView: UIView {
    private let radius: CGFloat = 12
    private let shadowRadius: CGFloat = 15
    private let shadowOpacity: Float = 0.3
    private let userImageButtonSize: CGFloat = 50
    
    private weak var delegate: UserInfoPushable?
    private var isLogined: Bool = false
    
    private let baseImage: UIImage? = {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .regular, scale: .large)
        return UIImage(systemName: "person.fill", withConfiguration: largeConfig)
    }()
    private let settingImage: UIImage? = {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .small)
        return UIImage(systemName: "gearshape", withConfiguration: largeConfig)
    }()
    private lazy var userImageButton: UIButton = {
        let button = UIButton()
        button.setImage(self.baseImage, for: .normal)
        button.tintColor = UIColor.darkGray
        button.layer.cornerRadius = userImageButtonSize/2
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.clipsToBounds = true
        return button
    }()
    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = UIColor.darkGray
        label.contentMode = .center
        return label
    }()
    private lazy var userSettingButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor.lightGray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        button.contentMode = .left
        button.addTarget(self, action: #selector(self.showUserSetting), for: .touchUpInside)
        return button
    }()
    private lazy var settingButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.systemGray6
        button.setTitle("설정", for: .normal)
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.setImage(self.settingImage, for: .normal)
        button.tintColor = UIColor.darkGray
        button.contentHorizontalAlignment = .left
        button.semanticContentAttribute = .forceRightToLeft
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 135, bottom: 0, right: -135)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(self.showSetting), for: .touchUpInside)
        return button
    }()
    
    convenience init() {
        self.init(frame: CGRect())
        self.configureLayout()
        self.refresh()
    }
    
    func configureDelegate(delegate: UserInfoPushable) {
        self.delegate = delegate
    }
    
    func refresh() {
        self.isLogined = UserDefaultsManager.get(forKey: .logined) as? Bool ?? false
        if self.isLogined {
            self.refreshUserInfo()
        } else {
            self.showLoginText()
        }
    }
    
    private func refreshUserInfo() {
        if let userInfo = CoreUsecase.fetchUserInfo(), let name = userInfo.name {
            self.configureName(to: name)
            self.configureUserSettingButtonText(to: "개인정보 수정하기 >")
        } else {
            self.configureName(to: "환영합니다!")
            self.configureUserSettingButtonText(to: "로그인하기")
        }
    }
    
    private func showLoginText() {
        self.configureName(to: "환영합니다!")
        self.configureUserSettingButtonText(to: "로그인하기")
    }
    
    private func configureName(to name: String) {
        self.userNameLabel.text = name
    }
    
    private func configureUserSettingButtonText(to text: String) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.lightGray,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        let attributeString = NSMutableAttributedString(string: text, attributes: attributes)
        self.userSettingButton.setAttributedTitle(attributeString, for: .normal)
    }
    
    private func configureLayout() {
        self.addSubviews(self.userImageButton, self.userNameLabel, self.userSettingButton, self.settingButton)
        
        self.backgroundColor = UIColor.white
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowOpacity = self.shadowOpacity
        self.layer.shadowRadius = self.radius
        self.layer.cornerRadius = self.shadowRadius
        self.clipsToBounds = false
        
        NSLayoutConstraint.activate([
            self.userImageButton.widthAnchor.constraint(equalToConstant: userImageButtonSize),
            self.userImageButton.heightAnchor.constraint(equalToConstant: userImageButtonSize),
            self.userImageButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            self.userImageButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20)
        ])
        
        NSLayoutConstraint.activate([
            self.userNameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 22),
            self.userNameLabel.leadingAnchor.constraint(equalTo: self.userImageButton.trailingAnchor, constant: 20),
        ])
        
        NSLayoutConstraint.activate([
            self.userSettingButton.topAnchor.constraint(equalTo: self.userNameLabel.bottomAnchor),
            self.userSettingButton.leadingAnchor.constraint(equalTo: self.userNameLabel.leadingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.settingButton.heightAnchor.constraint(equalToConstant: 50),
            self.settingButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
            self.settingButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            self.settingButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20)
        ])
    }
}

extension UserInfoToggleView {
    @objc func showUserSetting() {
        if self.isLogined {
            self.delegate?.showUserSetting()
        } else {
            self.delegate?.showLoginVC()
        }
    }
    
    @objc func showSetting() {
        self.delegate?.showSetting()
    }
}
