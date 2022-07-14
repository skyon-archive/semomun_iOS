//
//  GoogleLoginButton.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/14.
//

import UIKit

final class GoogleLoginButton: UIButton {
    convenience init() {
        self.init(frame: CGRect())
        self.configureLayout()
    }
    
    private func configureLayout() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.getSemomunColor(.white)
        self.titleLabel?.font = UIFont.heading3
        self.setTitleColor(UIColor.getSemomunColor(.black).withAlphaComponent(0.54), for: .normal)
        self.setTitle("Google로 로그인", for: .normal)
        self.setImage(UIImage(.GoogleLogo), for: .normal)
        self.layer.cornerRadius = 10
        self.layer.cornerCurve = .continuous
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.getSemomunColor(.border).cgColor
        
        self.contentEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: 345),
            self.heightAnchor.constraint(equalToConstant: 54)
        ])
    }
}
