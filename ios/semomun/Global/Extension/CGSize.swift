//
//  CGSize.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/06/10.
//

import UIKit

extension CGSize {
    var hasValidSize: Bool {
        return self.width * self.height > 0
    }
}
