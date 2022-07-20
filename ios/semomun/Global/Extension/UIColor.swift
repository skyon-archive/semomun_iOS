//
//  UIColor.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/02/04.
//

import UIKit

extension UIColor {
    @available(*, deprecated, message: "getSemomunColor를 사용하세요")
    convenience init?(_ semomunColor: SemomunColor) {
        self.init(named: semomunColor.rawValue)
    }
    
    static func getSemomunColor(_ semomunColor: SemomunColor) -> UIColor {
        if let color = UIColor(semomunColor) {
            return color
        } else {
            assertionFailure("존재하지 않는 색입니다.")
            return .black
        }
    }
    
    convenience init(hex: UInt, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
