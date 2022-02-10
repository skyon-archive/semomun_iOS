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
    
    func addShadow(direction: CALayer.ShadowDirection = .center) {
        self.layer.configureShadow(direction: direction, cornerRadius: self.layer.cornerRadius, backgroundColor: self.backgroundColor?.cgColor)
    }
    
    /// - Note: Rasterize가 적용된 그림자가 추가됩니다.
    /// - Warning: sublayer를 추가하기 때문에 viewDidLoad가 아닌 viewDidLayoutSubview등에서 호출해야합니다.
    func addAccessibleShadow(direction: CALayer.ShadowDirection = .center) {
        let shadowLayer = self.layer.sublayers?.first(where: { $0.name == Self.shadowLayerName }) ?? CAShapeLayer()
        shadowLayer.name = Self.shadowLayerName
        shadowLayer.configureShadow(direction: direction, cornerRadius: self.layer.cornerRadius, backgroundColor: self.backgroundColor?.cgColor, bounds: self.layer.bounds, shouldRasterize: true)
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
    
    func clipAccessibleShadow(at direction: ShadowClipDirection) {
        guard let shadowLayer = self.layer.sublayers?.first(where: { $0.name == Self.shadowLayerName }) else { return }
        let shadowRadius: CGFloat = shadowLayer.shadowRadius * 2 // 왜 곱하기 2를 해야 될까🤔
        let shadowLayerHeight = shadowLayer.frame.height
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
        shadowLayer.clipLayer(rect: CGRect(x, y, w, h))
    }
    
    func removeClipOfAccessibleShadow() {
        guard let shadowLayer = self.layer.sublayers?.first(where: { $0.name == Self.shadowLayerName }) else { return }
        shadowLayer.mask = nil
    }
}
