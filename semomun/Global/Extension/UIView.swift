//
//  UIView.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/18.
//

import Foundation
import UIKit

extension UIView {
    static let shadowLayerName = "ShadowLayer"
    
    func addSubviews(_ views: UIView...) {
        views.forEach { view in
            self.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    enum ShadowDirection {
        case center, bottom, top, diagnal
    }
    
    func addShadow(direction: ShadowDirection = .center, offset: CGSize? = nil, shouldRasterize: Bool = false) {
        
        let shadowLayer = self.layer.sublayers?.first(where: { $0.name == Self.shadowLayerName }) ?? CAShapeLayer()
        shadowLayer.name = Self.shadowLayerName
        shadowLayer.shadowOpacity = 0.3
        shadowLayer.frame = self.layer.bounds
        shadowLayer.cornerRadius = self.layer.cornerRadius
        // print(self.layer.bounds)
        shadowLayer.shadowColor = UIColor.lightGray.cgColor
        shadowLayer.shadowRadius = 5
        shadowLayer.backgroundColor = self.backgroundColor?.cgColor
        shadowLayer.shadowPath = UIBezierPath(roundedRect: self.layer.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        shadowLayer.shouldRasterize = shouldRasterize
        
        if let offset = offset {
            shadowLayer.shadowOffset = offset
        } else {
            switch direction {
            case .center:
                shadowLayer.shadowOffset = CGSize(width: 0, height: 0)
            case .bottom:
                shadowLayer.shadowOffset = CGSize(width: 0, height: 2)
            case .top:
                shadowLayer.shadowOffset = CGSize(width: 0, height: -2)
            case .diagnal:
                shadowLayer.shadowOffset = CGSize(width: 1.4, height: 1.4)
            }
        }
        self.layer.insertSublayer(shadowLayer, at: 0)
    }
    
    func changeShadowOffset(to offset: CGSize) {
        guard let shadowLayer = self.layer.sublayers?.first(where: { $0.name == Self.shadowLayerName }) else {
            return
        }
        shadowLayer.shadowOffset = offset
    }
}
