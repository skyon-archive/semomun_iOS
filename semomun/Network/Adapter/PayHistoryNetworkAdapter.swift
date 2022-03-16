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
            let title = payHistoryOfDB.item.workbook.title
            let bookCoverImageID = payHistoryOfDB.item.workbook.bookcover
            return PurchasedItemNetworkAdapter(createdDate: date, amount: amount, title: title, bookCoverImageID: bookCoverImageID)
        }
    }
}

struct PurchasedItemNetworkAdapter: PurchasedItem {
    let createdDate: Date
    let transaction: Transaction
    let title: String
    let bookCoverImageID: UUID?
    
    init(createdDate: Date, amount: Int, title: String, bookCoverImageID: UUID? = nil) {
        self.createdDate = createdDate
        self.title = title
        self.bookCoverImageID = bookCoverImageID
        
        switch amount {
        case 0:
            self.transaction = .free
        case ..<0:
            self.transaction = .purchase(-amount)
        default:
            self.transaction = .charge(amount)
        }
    }
}
