//
//  ButtonWithImage.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/19.
//

import UIKit

final class ButtonWithImage: UIButton {
    init(image: SemomunImage, title: String, color: SemomunColor, action: @escaping () -> Void) {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setImageWithSVGTintColor(image: .init(image), color: color)
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = .heading5
        self.addAction(UIAction { _ in action() }, for: .touchUpInside)
        self.adjustsImageWhenHighlighted = false
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
