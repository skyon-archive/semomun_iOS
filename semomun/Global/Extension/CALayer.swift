//
//  CALayer.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/02/04.
//

import UIKit

extension CALayer {    
    func clipLayer(rect: CGRect) {
        let layer = CALayer()
        layer.backgroundColor = UIColor.white.cgColor
        layer.frame = rect
        self.mask = layer
    }
    
    enum ShadowDirection {
        case center, bottom, top, diagnal, right, left
    }
    
    func configureShadow(direction: ShadowDirection, cornerRadius: CGFloat, backgroundColor: CGColor?, bounds: CGRect? = nil, shouldRasterize: Bool = false) {
        self.shadowOpacity = 0.3
        self.shadowColor = UIColor.lightGray.cgColor
        self.shadowRadius = 5
        self.cornerRadius = cornerRadius
        self.shouldRasterize = shouldRasterize
        self.backgroundColor = backgroundColor
        if let bounds = bounds {
            self.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
            self.frame = bounds
        }
        self.shadowOffset = getShadowOffset(of: direction)
    }
    
    func removeShadow() {
        self.shadowOpacity = 0
        self.shadowOffset = CGSize(0, -3)
    }

    private func getShadowOffset(of shadowDirection: ShadowDirection) -> CGSize {
        switch shadowDirection {
        case .center:
            return CGSize(width: 0, height: 0)
        case .bottom:
            return CGSize(width: 0, height: 2)
        case .top:
            return CGSize(width: 0, height: -2)
        case .diagnal:
            return CGSize(width: 1.4, height: 1.4)
        case .right:
            return CGSize(width: -2, height:5)
        case .left:
            return CGSize(width: 2, height: 5)
        }
    }
}
