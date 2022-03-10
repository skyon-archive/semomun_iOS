//
//  BookshelfInfo.swift
//  semomun
//
//  Created by Kang Minsang on 2022/03/08.
//

import Foundation

struct BookshelfInfoOfDB: Decodable {
    let wid: Int
    let recentDate: Date?
    let purchasedDates: [PurchasedDate]
    
    enum CodingKeys: String, CodingKey {
        case wid
        case recentDate = "solve"
        case purchasedDates = "payHistory"
    }
}

struct PurchasedDate: Decodable {
    let purchased: Date
    
    enum CodingKeys: String, CodingKey {
        case purchased = "createdAt"
    }
}


struct BookshelfInfo {
    let wid: Int
    let recentDate: Date?
    let purchased: Date
    
    init(info: BookshelfInfoOfDB) {
        self.wid = info.wid
        self.recentDate = info.recentDate
        self.purchased = info.purchasedDates.first!.purchased // 구매내역은 1개이상, 구매일자는 필수로 존재
    }
}
