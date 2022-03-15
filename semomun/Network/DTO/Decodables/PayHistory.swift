//
//  PayHistory.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/26.
//

import Foundation

protocol PayHistoryGroupRepresentable {
    associatedtype Element: PayHistoryRepresentable
    var count: Int { get }
    var content: [Element] { get }
}

protocol PayHistoryRepresentable {
    var createdDate: Date { get }
    var transaction: Transaction { get }
    var title: String { get }
    var bookCover: UUID? { get }
}

enum Transaction {
    case charge(Int)
    case purchase(Int)
    case free
}

struct PayHistoryGroup: Decodable {
    enum CodingKeys: String, CodingKey {
        case count
        case content = "history"
    }
    let count: Int
    var content: [PayHistory]
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

// MARK: Protocol conformance for UI
extension PayHistoryGroup: PayHistoryGroupRepresentable { }

extension PayHistory: PayHistoryRepresentable {
    var title: String {
        self.item.workbook.title
    }
    
    var bookCover: UUID? {
        self.item.workbook.bookcover
    }
}
