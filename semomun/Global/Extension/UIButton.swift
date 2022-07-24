//
//  UIButton.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/05.
//

import UIKit

extension UIButton {
    func setImageWithSVGTintColor(semomunImage: SemomunImage, color: SemomunColor) {
        self.setImageWithSVGTintColor(image: UIImage(semomunImage), color: color)
    }
    
    func setImageWithSVGTintColor(image: UIImage, color: SemomunColor) {
        let image = image.withRenderingMode(.alwaysTemplate)
        self.setImage(image, for: .normal)
        self.setTitleColor(UIColor.getSemomunColor(color), for: .normal)
        self.tintColor = UIColor.getSemomunColor(color)
    }
    
    func setTitleUnderline() {
        guard let title = title(for: .normal) else { return }
        let attributedString = NSMutableAttributedString(string: title)
        attributedString.addAttribute(.underlineStyle,
                                      value: NSUnderlineStyle.single.rawValue,
                                      range: NSRange(location: 0, length: title.count)
        )
        setAttributedTitle(attributedString, for: .normal)
    }
}
