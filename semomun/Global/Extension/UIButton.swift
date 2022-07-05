//
//  UIButton.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/05.
//

import UIKit

extension UIButton {
    func setSVGTintColor(to color: UIColor) {
        self.imageView?.image = self.imageView?.image?.withRenderingMode(.alwaysTemplate)
        self.imageView?.tintColor = color
    }
}
