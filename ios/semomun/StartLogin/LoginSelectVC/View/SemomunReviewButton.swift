//
//  SemomunReviewButton.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/14.
//

import UIKit

final class SemomunReviewButton: UIButton {
    convenience init() {
        self.init(frame: CGRect())
        self.configureLayout()
    }
    
    private func configureLayout() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.getSemomunColor(.blueRegular)
        self.titleLabel?.font = UIFont.heading3
        self.setTitleColor(UIColor.getSemomunColor(.white), for: .normal)
        self.setTitle("세모문으로 로그인", for: .normal)
        self.layer.cornerRadius = 10
        self.layer.cornerCurve = .continuous
        
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: 345),
            self.heightAnchor.constraint(equalToConstant: 54)
        ])
        self.addShadow(direction: .bottom)
    }
}
