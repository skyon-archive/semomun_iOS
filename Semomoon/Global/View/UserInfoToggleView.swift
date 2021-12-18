//
//  UserInfoToggleView.swift
//  Semomoon
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
        button.addTarget(self, action: #selector(showUserSetting), for: .touchUpInside)
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
        self.addSubviews(self.userImageButton, self.userNameLabel, self.userSettingButton)
        
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
    }
    
    func configureName(to name: String) {
        self.userNameLabel.text = name
    }
}

extension UserInfoToggleView {
    @objc func showUserSetting() {
        self.delegate?.showSetting()
    }
    
    @objc func showSetting() {
        self.delegate?.showSetting()
    }
}
