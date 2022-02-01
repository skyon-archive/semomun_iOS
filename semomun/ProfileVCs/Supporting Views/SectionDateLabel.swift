//
//  SectionDateLabel.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/02/01.
//

import UIKit

class SectionDateLabel: UILabel {
    convenience init(text: String, filled: Bool) {
        self.init(frame: CGRect(0, 0, 113, 28))
        guard let mainColor = UIColor(named: "mainColor") else { return }
        guard let backgroundColor = UIColor(named: "tableViewBackground") else { return }
        self.text = text
        self.backgroundColor = filled ? mainColor : backgroundColor
        self.clipsToBounds = true
        self.font = .systemFont(ofSize: 14, weight: .medium)
        self.textColor = filled ? .white : mainColor
        self.textAlignment = .center
        self.layer.borderColor = mainColor.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 14
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
