//
//  UIButton.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/05.
//

import UIKit

extension UIButton {
    func setImageWithSVGTintColor(image: UIImage, color: SemomunColor) {
        let image = image.withRenderingMode(.alwaysTemplate)
        self.setImage(image, for: .normal)
        self.setTitleColor(UIColor.getSemomunColor(color), for: .normal)
        self.tintColor = UIColor.getSemomunColor(color)
    }
}
