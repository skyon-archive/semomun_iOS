//
//  WorkbookGroupOfDB.swift
//  semomun
//
//  Created by Kang Minsang on 2022/06/21.
//

import Foundation

struct WorkbookGroupOfDB: Decodable {
    let wgid: Int
    let itemID: Int
    let type: String
    let title: String
    let detail: String
    let groupCover: UUID
    let isGroupOnlyPurchasable: Bool
    let createdDate: Date
    let updatedDate: Date
    let workbooks: [WorkbookOfDB]
    
    enum CodingKeys: String, CodingKey {
        case wgid
        case itemID = "id"
        case type, title, detail, groupCover, isGroupOnlyPurchasable
        case createdDate = "createdAt"
        case updatedDate = "updatedAt"
        case workbooks
    }
}
