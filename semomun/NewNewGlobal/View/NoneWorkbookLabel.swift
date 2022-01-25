//
//  NoneWorkbookLabel.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/25.
//

import UIKit

class NoneWorkbookLabel: UILabel {
    convenience init() {
        self.init(frame: CGRect())
        self.commonInit()
    }
    
    private func commonInit() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        self.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        self.textColor = .black
        self.textAlignment = .left
        self.numberOfLines = 2
    }
}
