//
//  Workbook.swift
//  Workbook
//
//  Created by qwer on 2021/09/05.
//

import Foundation

struct Workbook: Codable {
    var wid: Int
    var year: Int
    var month: Int
    var price: Int
    var detail: String
    var image: Int
    var sales: Int
    var publisher: String
    var category: String
    var subject: String
}
