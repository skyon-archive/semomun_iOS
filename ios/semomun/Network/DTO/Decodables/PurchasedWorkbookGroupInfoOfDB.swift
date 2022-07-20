//
//  PurchasedWorkbookGroupInfoOfDB.swift
//  semomun
//
//  Created by Kang Minsang on 2022/06/23.
//

import Foundation

struct PurchasedWorkbookGroupInfoOfDB: Decodable {
    let wgid: Int
    let recentDate: Date?
    let purchasedDate: Date?
    let wids: [Int]
    
    enum CodingKeys: String, CodingKey {
        case wgid
        case recentDate = "solve"
        case purchasedDate = "createdAt"
        case wids = "workbooks"
    }
}
