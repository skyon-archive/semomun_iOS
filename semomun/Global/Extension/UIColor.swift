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
}
