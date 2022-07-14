//
//  SignupButton.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/14.
//

import UIKit

final class SignupButton: UIButton {
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.heading5
        label.textColor = UIColor.getSemomunColor(.lightGray)
        label.text = "계정이 없으신가요?"
        return label
    }()
    convenience init() {
        self.init(frame: CGRect())
        self.configureLayout()
    }
    
    private func configureLayout() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.getSemomunColor(.white)
        self.titleLabel?.font = UIFont(name: UIFont.boldFont, size: 16)
        self.setTitleColor(UIColor.getSemomunColor(.orangeRegular), for: .normal)
        self.setTitle("회원가입", for: .normal)
        self.setUnderline()
        
        self.contentEdgeInsets = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: 345),
            self.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        self.addSubview(self.descriptionLabel)
        NSLayoutConstraint.activate([
            self.descriptionLabel.topAnchor.constraint(equalTo: self.topAnchor),
            self.descriptionLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
    }
}
