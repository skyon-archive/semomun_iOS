//
//  Collection.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/02/24.
//

import Foundation

extension Collection {
    subscript (safe index: Index) -> Element? {
        return self.indices.contains(index) ? self[index] : nil
    }
}
