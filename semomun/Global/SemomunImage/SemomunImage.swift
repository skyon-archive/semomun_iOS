//
//  SemomunImage.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/03.
//

import Foundation

enum SemomunImage: ImageName {
    case addButton = "/addButton"
    case warning = "/warning"
    case empty = "/empty"
    case dummy_bookcover = "/dummy_bookcover"
    case loadingBookcover = "text.book.closed"
    case dummy_ad = "/dummy_ad"
    case clock = "/clock"
    case xmark = "xmark"
    case answerImage = "/answerImage"
    case circleCheckmark = "checkmark.circle"
    case circleCheckmarkFilled = "checkmark.circle.fill"
    case googleLogo = "/googleLogo"
    case exclamationmarkTriangle = "exclamationmark.triangle"
}

struct ImageName: Equatable, ExpressibleByStringLiteral {
    let isSFSymbol: Bool
    let name: String
    
    init(stringLiteral value: String) {
        if value.hasPrefix("/") {
            self.isSFSymbol = false
            self.name = String(value.dropFirst())
        } else {
            self.isSFSymbol = true
            self.name = value
        }
    }
    
}
