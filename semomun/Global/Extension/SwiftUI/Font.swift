//
//  Font.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/26.
//

import SwiftUI
import UIKit

public extension Font {
    init(uiFont: UIFont) {
        self = Font(uiFont as CTFont)
    }
}
