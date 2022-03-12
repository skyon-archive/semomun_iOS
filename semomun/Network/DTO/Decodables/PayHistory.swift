//
//  PayHistory.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/26.
//

import Foundation

struct PayHistoryGroup: Decodable {
    enum CodingKeys: String, CodingKey {
        case count
        case content = "history"
    }
    let count: Int
    var content: [PayHistory]
}

enum Transaction {
    case charge(Int)
    case purchase(Int)
    case free
}

struct PayHistory: Decodable {
    enum CodingKeys: String, CodingKey {
        case item, amount
        case createdDate = "createdAt"
    }
    
    var transaction: Transaction {
        switch self.amount {
        case 0:
            return .free
        case ..<0:
            return .purchase(-self.amount)
        default:
            return .charge(self.amount)
        }
    }
    
    let item: PurchasedItem
    let createdDate: Date
    
    private let amount: Int
}

struct PurchasedItem: Codable {
    let workbook: PurchasedWorkbook
}

struct PurchasedWorkbook: Codable {
    let title: String
    let bookcover: UUID
}
