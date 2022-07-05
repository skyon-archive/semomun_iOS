//
//  UIImage.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/02/11.
//

import UIKit

extension UIImage {
    convenience init(_ semomunImage: SemomunImage, withConfiguration configuration: UIImage.SymbolConfiguration? = nil) {
        if let _ = UIImage(named: semomunImage.rawValue) {
            self.init(named: semomunImage.rawValue)!
        } else {
            self.init(named: "warning")!
        }
    }
}
