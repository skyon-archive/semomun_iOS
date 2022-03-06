//
//  SchoolDTO.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2021/12/28.
//

import Foundation

struct CareerNetJSON: Decodable {
    let dataSearch: DataSearch
}

struct DataSearch: Decodable {
    let content: [SchoolContent]
}

struct SchoolContent: Decodable {
    let schoolName: String
}
