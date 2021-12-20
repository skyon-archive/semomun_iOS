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
}

final class UserInfoToggleView: UIView {
    private let radius: CGFloat = 12
    private let shadowRadius: CGFloat = 15
    private let shadowOpacity: Float = 0.3
    private weak var delegate: UserInfoPushable?
    
    let baseImage: UIImage? = {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .regular, scale: .large)
        return UIImage(systemName: "person.fill", withConfiguration: largeConfig)
    }()
    let settingImage: UIImage? = {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .small)
        return UIImage(systemName: "gearshape", withConfiguration: largeConfig)
    }()
    private lazy var userImageButton: UIButton = {
        let button = UIButton()
        button.setImage(self.baseImage, for: .normal)
        button.tintColor = UIColor.darkGray
        button.layer.cornerRadius = 25
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
        button.setTitle("개인정보 수정하기 >", for: .normal)
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
        self.configureName(to: "홍길동")
    }
    
    func configureDelegate(delegate: UserInfoPushable) {
        self.delegate = delegate
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
            self.userImageButton.widthAnchor.constraint(equalToConstant: 50),
            self.userImageButton.heightAnchor.constraint(equalToConstant: 50),
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
    
    func configureName(to name: String) {
        self.userNameLabel.text = name
    }
}

extension UserInfoToggleView {
    @objc func showUserSetting() {
        self.delegate?.showUserSetting()
    }
    
    @objc func showSetting() {
        self.delegate?.showSetting()
    }
}
