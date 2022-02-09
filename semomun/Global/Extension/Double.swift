//
//  Double.swift
//  semomun
//
//  Created by Kang Minsang on 2022/02/08.
//

import Foundation

extension Double {
    var removeDecimalPoint: String {
        if self.truncatingRemainder(dividingBy: 1).isZero {
            return String(Int(self))
        } else {
            return String(self)
        }
    }
}
