//
//  CategoryOfDB.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/28.
//

import Foundation

struct SearchCategories: Decodable {
    let count: Int
    let categories: [CategoryOfDB]
}

struct CategoryOfDB: Equatable, Codable {
    let cid: Int
    let name: String
    let TagCount: Int?
}

