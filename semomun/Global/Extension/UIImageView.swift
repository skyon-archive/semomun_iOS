//
//  UIImageView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/05.
//

import UIKit

extension UIImageView {
    func changeImageColor(to color: UIColor) {
        self.image = self.image?.withRenderingMode(.alwaysTemplate)
        self.tintColor = color
    }
}
