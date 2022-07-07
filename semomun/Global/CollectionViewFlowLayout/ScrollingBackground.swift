//
//  ScrollingBackground.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/07.
//

import UIKit

class ScrollingBackground: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.getSemomunColor(.white)
        self.layer.masksToBounds = true
        self.cornerRadius = .cornerRadius24
        self.layer.cornerCurve = .continuous
        self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
