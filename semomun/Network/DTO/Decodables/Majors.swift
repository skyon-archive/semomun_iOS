//
//  Majors.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/27.
//

import Foundation

struct MajorFetched: Decodable {
    let major: [[String: [String]]]
}

struct Major {
    let name: String
    let details: [String]
}

