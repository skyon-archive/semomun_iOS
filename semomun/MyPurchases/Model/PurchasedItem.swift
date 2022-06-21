//
//  PurchasedItem.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/03/18.
//

import Foundation

struct PurchasedItem {
    let createdDate: Date
    let transaction: Transaction
    let title: String
    let descriptionImageID: UUID
    
    private let purchasedItem: PurchasedItemofDB
    
    init(purchasedItemofDB: PurchasedItemofDB, createdDate: Date, amount: Int) {
        self.purchasedItem = purchasedItemofDB
        self.createdDate = createdDate
        self.transaction = Transaction(amount: amount)
        self.title = purchasedItemofDB.workbook.title
        self.descriptionImageID = purchasedItemofDB.workbook.bookcover
    }
}

enum Transaction {
    case free
    case purchase(Int)
    case charge(Int)
    
    var amount: Int {
        switch self {
        case .purchase(let val), .charge(let val):
            return val
        case .free:
            return 0
        }
    }
    
    init(amount: Int) {
        switch amount{
        case 0:
            self = .free
        case ..<0:
            self = .purchase(-amount)
        default:
            self = .charge(amount)
        }
    }
}
