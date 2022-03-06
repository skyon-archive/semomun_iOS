//
//  AppstoreVersion.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/12.
//

import Foundation

struct AppstoreVersion: Decodable {
    let resultCount: Int
    let results: [Result]
}

struct Result: Decodable {
    let version: String
}
