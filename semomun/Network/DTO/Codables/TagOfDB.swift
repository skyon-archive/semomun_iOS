//
//  TagOfDB.swift
//  semomun
//
//  Created by Kang Minsang on 2022/03/03.
//

import Foundation

struct SearchTags: Decodable {
    let count: Int
    let tags: [TagOfDB]
}

struct TagOfDB: Equatable, Codable {
    let tid: Int
    let cid: Int
    let name: String
    let category: CategoryOfDB
}
