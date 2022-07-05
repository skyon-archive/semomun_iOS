//
//  UIImage.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/02/11.
//

import UIKit

extension UIImage {
    convenience init(_ semomunImage: SemomunImage, withConfiguration configuration: UIImage.SymbolConfiguration? = nil) {
        let imageName = semomunImage.rawValue
        if let _ = UIImage(named: imageName) {
            self.init(named: imageName)!
        } else {
            self.init(named: "warning")!
        }
    }
}
