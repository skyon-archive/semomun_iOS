//
//  AppstoreVersion.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/12.
//

import Foundation

struct AppstoreVersion: Decodable {
    let resultCount: Int
    let results: [AppStoreVersionResult]
}

struct AppStoreVersionResult: Decodable {
    let version: String
}
