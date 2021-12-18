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
    
    convenience init() {
        self.init(frame: CGRect())
        self.configureLayout()
    }
    
    func configureDelegate(delegate: UserInfoPushable) {
        self.delegate = delegate
    }
    
    private func configureLayout() {
        self.backgroundColor = UIColor.white
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowOpacity = self.shadowOpacity
        self.layer.shadowRadius = self.radius
        self.layer.cornerRadius = self.shadowRadius
        self.clipsToBounds = false
    }
}
