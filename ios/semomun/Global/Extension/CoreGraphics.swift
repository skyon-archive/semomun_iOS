//
//  CoreGraphics.swift
//  semomun
//
//  Created by Kang Minsang on 2022/03/02.
//

import CoreGraphics

extension CGSize {
    init(_ w: CGFloat, _ h: CGFloat) {
        self = CGSize(width: w, height: h)
    }
}

extension CGPoint {
    init(_ x: CGFloat, _ y: CGFloat) {
        self = CGPoint(x: x, y: y)
    }
}

extension CGRect {
    init(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) {
        self = CGRect(x: x, y: y, width: w, height: h)
    }
}
