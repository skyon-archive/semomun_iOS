//
//  QueryListButton.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/27.
//

import Foundation

struct CategoryQueryButtons: Codable, CustomStringConvertible {
    var description: String {
        return "\(self.queryButtons.map { $0.title })"
    }
    
    let queryButtons: [QueryListButton]
}

struct QueryListButton: Codable {
    let title: String
    let menus: [String]
    let queryParamKey: String
    let queryParamValues: [String]
}
