//
//  CorrectImageView.swift
//  semomun
//
//  Created by Kang Minsang on 2022/05/27.
//

import UIKit

final class CorrectImageView: UIImageView {
    convenience init() {
        self.init(frame: CGRect())
        self.commonInit()
    }
    
    private func commonInit() {
        self.backgroundColor = .clear
        self.contentMode = .scaleAspectFit
        self.isHidden = true
    }
    
    func show(isWrong: Bool) {
        self.image = isWrong ? UIImage(.wrong) : UIImage(.correct)
        self.isHidden = false
    }
    
    func adjustLayoutForCell(imageViewWidth: CGFloat) {
        guard self.isHidden == false else { return }
        let width = imageViewWidth/5
        let yOffset = (imageViewWidth/100) * 13.5 - (imageViewWidth/10)
        self.frame = .init(0, yOffset, width, width)
    }
    
    func adjustLayoutForZero(imageViewWidth: CGFloat) {
        guard self.isHidden == false else { return }
        let width = imageViewWidth/5
        let xOffset = (imageViewWidth/100)*19 - (imageViewWidth/10)
        self.frame = .init(xOffset, 0, width, width)
    }
}

