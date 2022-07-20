//
//  Int.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/31.
//

import Foundation

extension Int {
    var withComma: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        guard let formatted = numberFormatter.string(from: NSNumber(value: self)) else {
            assertionFailure()
            return "-"
        }
        return formatted
    }
    var withCommaAndSign: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.positivePrefix = numberFormatter.plusSign
        guard let formatted = numberFormatter.string(from: NSNumber(value: self)) else {
            assertionFailure()
            return "-"
        }
        return formatted
    }
    var byteToMBString: String {
        let size = Double(self)/1000000
        return String(format: "%.1fMB", size)
    }
    var toYearMonthDayString: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: TimeInterval(self)) ?? "00:00:00"
    }
}
