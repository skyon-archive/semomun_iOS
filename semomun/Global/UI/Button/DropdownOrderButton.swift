//
//  DropdownOrderButton.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/06.
//

import UIKit

final class DropdownOrderButton: UIButton {
    private lazy var leftIcon: UIImageView = {
        let imageView = UIImageView()
        
        return imageView
    }()
//    private lazy var
    convenience init() {
        self.init(type: .custom)
        self.commonInit()
    }
    
    private func commonInit() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setTitle("hello", for: .normal)
    }
}
