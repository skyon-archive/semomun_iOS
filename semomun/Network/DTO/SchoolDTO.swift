//
//  SchoolDTO.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2021/12/28.
//

import Foundation

struct CareerNetJSON: Codable {
    let dataSearch: DataSearch
}

struct DataSearch: Codable {
    let content: [SchoolContent]
}

struct SchoolContent: Codable {
    let schoolName: String
}
