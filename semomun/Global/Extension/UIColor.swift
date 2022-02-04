//
//  UIColor.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/02/04.
//

import UIKit

extension UIColor {
    convenience init?(_ semomunColor: SemomunColor) {
        self.init(named: semomunColor.rawValue)
    }
}
