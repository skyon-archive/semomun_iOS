//
//  BookshelfInfo.swift
//  semomun
//
//  Created by Kang Minsang on 2022/03/08.
//

import Foundation

struct BookshelfInfo: Decodable {
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
