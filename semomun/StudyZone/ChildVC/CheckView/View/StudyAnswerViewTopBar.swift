//
//  StudyAnswerViewTopBar.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/25.
//

import UIKit

final class StudyAnswerViewTopBar: UIView {
    convenience init() {
        self.init(frame: CGRect())
        self.translatesAutoresizingMaskIntoConstraints = false
        self.clipsToBounds = true
        self.layer.cornerRadius = 2
        self.layer.cornerCurve = .continuous
        self.backgroundColor = UIColor.getSemomunColor(.lightGray)
        
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 4),
            self.widthAnchor.constraint(equalToConstant: 40)
        ])
    }
}
