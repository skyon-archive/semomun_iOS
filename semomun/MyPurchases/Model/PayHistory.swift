//
//  PayHistory.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/03/16.
//

import Foundation

struct PayHistory {
    let count: Int
    let content: [PurchasedItem]
    
    init(networkDTO: PayHistoryGroupOfDB) {
        self.count = networkDTO.count
        self.content = networkDTO.content.map { payHistoryOfDB in
            let date = payHistoryOfDB.createdDate
            let amount = payHistoryOfDB.amount
            return PurchasedItem(purchasedItemofDB: payHistoryOfDB.item, createdDate: date, amount: amount)
        }
    }
}
