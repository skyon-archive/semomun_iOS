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

    @IBInspectable
    public var cornerRadius: CGFloat
    {
        set (radius) {
            self.layer.cornerRadius = radius
            self.layer.masksToBounds = radius > 0
        }

        get {
            return self.layer.cornerRadius
        }
    }

    @IBInspectable
    public var borderWidth: CGFloat
    {
        set (borderWidth) {
            self.layer.borderWidth = borderWidth
        }

        get {
            return self.layer.borderWidth
        }
    }

    @IBInspectable
    public var borderColor:UIColor?
    {
        set (color) {
            self.layer.borderColor = color?.cgColor
        }

        get {
            if let color = self.layer.borderColor
            {
                return UIColor(cgColor: color)
            } else {
                return nil
            }
        }
    }
    
    func addSubviews(_ views: UIView...) {
        views.forEach { view in
            self.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    enum ShadowDirection {
        case center, bottom, top, diagnal, right, left
    }
    
    /// - Warning: sublayer를 추가하기 때문에 viewDidLoad가 아닌 viewWillLayoutSubviews등에서 호출해야합니다.
    func addShadow(direction: ShadowDirection = .center, offset: CGSize? = nil, shouldRasterize: Bool = false) {
        let shadowLayer = self.layer.sublayers?.first(where: { $0.name == Self.shadowLayerName }) ?? CAShapeLayer()
        shadowLayer.name = Self.shadowLayerName
        shadowLayer.shadowOpacity = 0.3
        shadowLayer.frame = self.layer.bounds
        shadowLayer.cornerRadius = self.layer.cornerRadius
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
            case .right:
                shadowLayer.shadowOffset = CGSize(width: -2, height:5)
            case.left:
                shadowLayer.shadowOffset = CGSize(width: 2, height: 5)
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
    
    enum ShadowClipDirection {
        case top, bottom, both
    }
    
    func clipShadow(at direction: ShadowClipDirection) {
        guard let shadowLayer = self.layer.sublayers?.first(where: { $0.name == Self.shadowLayerName }) else { return }
        let shadowRadius: CGFloat = shadowLayer.shadowRadius * 2 // 왜 곱하기 2를 해야 될까🤔
        let shadowLayerHeight = shadowLayer.frame.height
        let layer = CALayer()
        layer.backgroundColor = UIColor.white.cgColor
        // 왼쪽부분 그림자는 항상 남음
        let x = -shadowRadius
        // 마찬가지로 좌우 그림자는 항상 남으므로 셀의 너비 + 양쪽 그림자의 넓이
        let w = shadowLayer.frame.width+2*shadowRadius
        let y, h: CGFloat
        switch direction {
        case .top:
            y = 0
            h = shadowLayerHeight+shadowRadius
        case .bottom:
            y = -shadowRadius
            h = shadowLayerHeight+shadowRadius
        case .both:
            y = 0
            h = shadowLayerHeight
        }
        layer.frame = CGRect(x, y, w, h)
        shadowLayer.mask = layer
    }
    
    func undoClipShadow() {
        guard let shadowLayer = self.layer.sublayers?.first(where: { $0.name == Self.shadowLayerName }) else { return }
        shadowLayer.mask = nil
    }
}
