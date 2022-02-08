//
//  Double.swift
//  semomun
//
//  Created by Kang Minsang on 2022/02/08.
//

import Foundation

extension Double {
    var removeDot: String {
        if "\(self)" == "\(Int(self)).0" {
            return "\(Int(self))"
        } else {
            return "\(self)"
        }
    }
}
