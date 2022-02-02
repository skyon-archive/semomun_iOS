//
//  Int.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/31.
//

import Foundation

extension Int {
    var withComma: String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value:self))
    }
    var withCommaAndSign: String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.positivePrefix = numberFormatter.plusSign
        return numberFormatter.string(from: NSNumber(value:self))
    }
}
