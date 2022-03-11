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
    let content: [PayHistory]
}

struct PayHistory: Decodable {
    let amount: Int /// 양수면 충전, 음수 또는 0이면 구매
    let item: PurchasedItem
}

struct PurchasedItem: Codable {
    let workbook: PurchasedWorkbook
}

struct PurchasedWorkbook: Codable {
    let title: String
    let bookcover: UUID
}
