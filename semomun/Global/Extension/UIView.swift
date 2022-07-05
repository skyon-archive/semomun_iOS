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
    
    func layoutConstraintActivates(_ layouts: [NSLayoutConstraint]...) {
        layouts.forEach { layout in
            NSLayoutConstraint.activate(layout)
        }
    }
    
    func addShadow(direction: CALayer.ShadowDirection = .center) {
        self.layer.configureShadow(direction: direction, cornerRadius: self.layer.cornerRadius, backgroundColor: self.backgroundColor?.cgColor)
    }
    
    func removeShadow() {
        self.layer.removeShadow()
    }
    
    /// 그림자를 위한 frameView에 그림자를 추가합니다.
    func addShadowToFrameView(cornerRadius: CGFloat) {
        self.clipsToBounds = false
        self.layer.masksToBounds = false
        self.layer.cornerRadius = cornerRadius
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = 0.05
        self.layer.shadowRadius = 8
    }
    
    /// - Note: Rasterize가 적용된 그림자가 추가됩니다.
    /// - Warning: sublayer를 추가하기 때문에 viewDidLoad가 아닌 viewDidLayoutSubview등에서 호출해야합니다.
    func addAccessibleShadow(direction: CALayer.ShadowDirection = .center, opacity: Float = 0.3, shadowRadius: CGFloat = 5, bounds: CGRect? = nil) {
        let shadowLayer = self.layer.sublayers?.first(where: { $0.name == Self.shadowLayerName }) ?? CAShapeLayer()
        shadowLayer.name = Self.shadowLayerName
        shadowLayer.configureShadow(direction: direction, cornerRadius: self.layer.cornerRadius, backgroundColor: self.backgroundColor?.cgColor, opacity: opacity, shadowRadius: shadowRadius, bounds: bounds ?? self.layer.bounds, shouldRasterize: true)
        if self.layer.sublayers?.contains(shadowLayer) != true {
            self.layer.insertSublayer(shadowLayer, at: 0)
        }
    }
    
    func changeShadowOffset(to offset: CGSize) {
        guard let shadowLayer = self.layer.sublayers?.first(where: { $0.name == Self.shadowLayerName }) else {
            return
        }
        shadowLayer.shadowOffset = offset
    }
    
    enum ShadowClipDirection {
        case top, bottom, both, exceptTop, exceptLeft
    }
    
    func clipAccessibleShadow(at direction: ShadowClipDirection) {
        guard let shadowLayer = self.layer.sublayers?.first(where: { $0.name == Self.shadowLayerName }) else {
            assertionFailure("그림자 레이어가 존재하지 않습니다.")
            return
        }
        let shadowRadius: CGFloat = shadowLayer.shadowRadius * 2 // 왜 곱하기 2를 해야 될까
        let shadowLayerHeight = shadowLayer.frame.height
        
        var x = -shadowRadius
        var w = shadowLayer.frame.width+2*shadowRadius
        let y, h: CGFloat
        
        switch direction {
        case .top:
            y = 0
            h = shadowLayerHeight+shadowRadius
        case .bottom:
            y = -shadowRadius
            h = shadowLayerHeight+shadowRadius
        case .exceptTop:
            x = 0
            y = -shadowRadius
            w = shadowLayer.frame.width
            h = shadowLayerHeight+shadowRadius
        case .both:
            y = 0
            h = shadowLayerHeight
        case .exceptLeft:
            y = 0
            w = shadowLayer.frame.width + shadowRadius
            h = shadowLayerHeight
        }
        shadowLayer.clipLayer(rect: CGRect(x, y, w, h))
    }
    
    func removeAccessibleShadow() {
        guard let shadowLayer = self.layer.sublayers?.first(where: { $0.name == Self.shadowLayerName }) else {
            return
        }
        shadowLayer.removeFromSuperlayer()
    }
    
    func removeClipOfAccessibleShadow() {
        guard let shadowLayer = self.layer.sublayers?.first(where: { $0.name == Self.shadowLayerName }) else { return }
        shadowLayer.mask = nil
    }
}
