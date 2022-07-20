//
//  WorkbookGroupResultButton.swift
//  semomun
//
//  Created by Kang Minsang on 2022/06/20.
//

import UIKit

final class WorkbookGroupResultButton: UIButton {
    convenience init() {
        self.init(type: .custom)
        self.commonInit()
    }
    
    override var isEnabled: Bool {
        didSet {
            let semomunColor: SemomunColor = self.isEnabled ? .blueRegular : .lightGray
            let color = UIColor.getSemomunColor(semomunColor)
            
            self.setTitleColor(color, for: .normal)
            self.tintColor = color
        }
    }
    
    private func commonInit() {
        self.frame = .init(0, 0, 130, 42)
        self.titleLabel?.font = .heading5
        self.setTitle("종합성적표", for: .normal)
        let image = UIImage(.clipboardCheckOutline).withRenderingMode(.alwaysTemplate)
        self.setImage(image, for: .normal)
        self.contentEdgeInsets = .zero
        self.sizeToFit()
        self.isEnabled = false
    }
}
