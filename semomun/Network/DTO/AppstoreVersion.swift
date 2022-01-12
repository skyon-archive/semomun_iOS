//
//  AppstoreVersion.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/12.
//

import Foundation

struct AppstoreVersion: Codable {
    let resultCount: Int
    let results: [Result]
}

struct Result: Codable {
    let version: String
}
