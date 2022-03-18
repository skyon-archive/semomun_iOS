//
//  PayHistoryofDB.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/26.
//

import Foundation

struct PayHistoryGroupOfDB: Decodable {
    enum CodingKeys: String, CodingKey {
        case count
        case content = "history"
    }
    let count: Int
    var content: [PayHistoryofDB]
}

struct PayHistoryofDB: Decodable {
    enum CodingKeys: String, CodingKey {
        case item, amount
        case createdDate = "createdAt"
    }
    
    let item: PurchasedItemofDB
    let createdDate: Date
    let amount: Int
}

struct PurchasedItemofDB: Codable {
    let workbook: PurchasedWorkbookofDB
}

struct PurchasedWorkbookofDB: Codable {
    let title: String
    let bookcover: UUID
}
