//
//  PayHistory.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/03/16.
//

import Foundation

protocol PayHistory {
    associatedtype Item: PurchasedItem
    
    var count: Int { get }
    var content: [Item] { get }
}

protocol PurchasedItem {
    var createdDate: Date { get }
    var transaction: Transaction { get }
    var title: String { get }
    var bookCoverImageID: UUID? { get }
}

enum Transaction {
    case charge(Int)
    case purchase(Int)
    case free
    var amount: Int {
        switch self {
        case .charge(let int), .purchase(let int):
            return int
        case .free:
            return 0
        }
    }
}
