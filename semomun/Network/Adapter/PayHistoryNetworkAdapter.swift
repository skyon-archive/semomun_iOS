//
//  PayHistoryNetworkAdapter.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/03/16.
//

import Foundation

struct PayHistoryNetworkAdapter: PayHistory {
    typealias Item = PurchasedItemNetworkAdapter
    
    let count: Int
    let content: [Item]
    
    init(networkDTO: PayHistoryGroupOfDB) {
        self.count = networkDTO.count
        self.content = networkDTO.content.map { payHistoryOfDB in
            let date = payHistoryOfDB.createdDate
            let amount = payHistoryOfDB.amount
            return PurchasedItemNetworkAdapter(purchasedItemofDB: payHistoryOfDB.item, createdDate: date, amount: amount)
        }
    }
}

struct PurchasedItemNetworkAdapter: PurchasedItem {
    let createdDate: Date
    let transaction: Transaction
    let title: String
    let bookCoverImageID: UUID?
    
    private let purchasedItem: PurchasedItemofDB
    
    init(purchasedItemofDB: PurchasedItemofDB, createdDate: Date, amount: Int) {
        self.purchasedItem = purchasedItemofDB
        self.createdDate = createdDate
        self.title = purchasedItemofDB.workbook.title
        self.bookCoverImageID = purchasedItemofDB.workbook.bookcover
        
        switch amount{
        case 0:
            self.transaction = .free
        case ..<0:
            self.transaction = .purchase(-amount)
        default:
            self.transaction = .charge(amount)
        }
    }
}
