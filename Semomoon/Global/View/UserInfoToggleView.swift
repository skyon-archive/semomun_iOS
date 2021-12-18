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
    lazy var userImageButton: UIButton = {
        let button = UIButton()
        button.setImage(self.baseImage, for: .normal)
        button.tintColor = UIColor.darkGray
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.clipsToBounds = true
        return button
    }()
    
    convenience init() {
        self.init(frame: CGRect())
        self.configureLayout()
    }
    
    func configureDelegate(delegate: UserInfoPushable) {
        self.delegate = delegate
    }
    
    private func configureLayout() {
        self.addSubviews(self.userImageButton)
        
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
            self.userImageButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            self.userImageButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10)
        ])
    }
}
