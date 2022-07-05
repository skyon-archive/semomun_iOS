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
        if imageName.isSFSymbol {
            self.init(systemName: imageName.name, withConfiguration: configuration)!
        } else {
            if let _ = UIImage(named: imageName.name) {
                self.init(named: imageName.name)!
            } else {
                self.init(named: "warning")!
            }
        }
    }
}
