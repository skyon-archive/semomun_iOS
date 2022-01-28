//
//  Majors.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/27.
//

import Foundation

struct MajorFetched: Codable {
    let major: [[String: [String]]]
}

struct Major {
    let name: String
    let details: [String]
}

