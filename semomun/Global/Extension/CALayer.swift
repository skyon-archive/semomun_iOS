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
        case center, bottom, top, diagnal
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

    private func getShadowOffset(of shadowDirection: ShadowDirection) -> CGSize {
        switch shadowDirection {
        case .center:
            shadowLayer.shadowOffset = CGSize(width: 0, height: 0)
        case .bottom:
            shadowLayer.shadowOffset = CGSize(width: 0, height: 2)
        case .top:
            shadowLayer.shadowOffset = CGSize(width: 0, height: -2)
        case .diagnal:
            shadowLayer.shadowOffset = CGSize(width: 1.4, height: 1.4)
        case .right:
            shadowLayer.shadowOffset = CGSize(width: -2, height:5)
        case .left:
            shadowLayer.shadowOffset = CGSize(width: 2, height: 5)
        }
    }
}
