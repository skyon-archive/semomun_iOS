//
//  AppleLoginButton.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/14.
//

import UIKit

final class AppleLoginButton: UIButton {
    convenience init() {
        self.init(frame: CGRect())
        self.configureLayout()
    }
    
    private func configureLayout() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.getSemomunColor(.black)
        self.titleLabel?.font = UIFont.heading3
        self.setTitleColor(UIColor.getSemomunColor(.white), for: .normal)
        self.setTitle("Apple로 로그인", for: .normal)
        self.setImage(UIImage(.AppleLogo), for: .normal)
        self.layer.cornerRadius = 10
        self.layer.cornerCurve = .continuous
        
        self.contentEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: 345),
            self.heightAnchor.constraint(equalToConstant: 54)
        ])
        self.addShadow(direction: .bottom)
    }
}
