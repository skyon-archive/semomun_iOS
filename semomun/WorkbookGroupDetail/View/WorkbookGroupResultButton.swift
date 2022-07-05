//
//  WorkbookGroupResultButton.swift
//  semomun
//
//  Created by Kang Minsang on 2022/06/20.
//

import UIKit

final class WorkbookGroupResultButton: UIButton {
    convenience init() {
        self.init(frame: CGRect())
        self.commonInit()
    }
    
    override var isEnabled: Bool {
        didSet {
            if self.isEnabled {
                self.borderColor = UIColor(.blueRegular)
                self.setTitleColor(UIColor(.blueRegular), for: .normal)
            } else {
                self.borderColor = UIColor(.lightGray)
                self.setTitleColor(UIColor(.lightGray), for: .normal)
            }
        }
    }
    
    private func commonInit() {
        self.frame = .init(0, 0, 130, 42)
        self.borderColor = UIColor(.blueRegular)
        self.borderWidth = 1
        self.cornerRadius = 5
        
        let clipboardImage = UIImage(.clipboardCheckOutline)
        let clipboardImageView = UIImageView(image: clipboardImage)
        clipboardImageView.changeImageColor(to: UIColor.getSemomunColor(.blueRegular))
        
        self.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        self.setTitleColor(UIColor(.blueRegular), for: .normal)
        self.setTitle("종합성적표 확인", for: .normal)
    }
}
