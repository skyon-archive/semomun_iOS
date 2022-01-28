//
//  UIView.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/18.
//

import Foundation
import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { view in
            self.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    enum ShadowDirection {
        case center, bottom, top, diagnal
    }
    
    func addShadow(direction: ShadowDirection = .center) {
        self.layer.shadowOpacity = 0.3
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowRadius = 5
        switch direction {
        case .center:
            self.layer.shadowOffset = CGSize(width: 0, height: 0)
        case .bottom:
            self.layer.shadowOffset = CGSize(width: 0, height: 3)
        case .top:
            self.layer.shadowOffset = CGSize(width: 0, height: -3)
        case .diagnal:
            self.layer.shadowOffset = CGSize(width: 1.7, height: 1.7)
        }
    }
}
