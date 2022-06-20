//
//  WorkbookGroupOfDB.swift
//  semomun
//
//  Created by Kang Minsang on 2022/06/20.
//

import Foundation

struct SearchWorkbookGroups: Decodable {
    let count: Int
    let workbookGroups: [WorkbookGroupOfDB]
}

struct WorkbookGroupOfDB: Decodable {
    let wgid: Int
    let itemId: Int
    let type: String
    let title: String
    let detail: String
    let groupCover: UUID
    let isGroupOnlyPurchasable: Bool
    let createdDate: Date
    let updatedDate: Date
    
    enum CodingKeys: String, CodingKey {
        case wgid
        case itemId = "id"
        case type, title, detail, groupCover, isGroupOnlyPurchasable
        case createdDate = "createdAt"
        case updatedDate = "updatedAt"
    }
}
