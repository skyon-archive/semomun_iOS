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
    let detail: String // 현재로썬 안쓰이는 값, 빈배열로 수신
    let groupCover: UUID
    let isGroupOnlyPurchasable: Bool // 전체구매만 가능한지 여부
    let createdDate: Date
    let updatedDate: Date
    let workbooks: [WorkbookOfDB] // GET /workbooks/:wid 들의 배열 형태
    
    enum CodingKeys: String, CodingKey {
        case wgid
        case itemID = "id"
        case type, title, detail, groupCover, isGroupOnlyPurchasable
        case createdDate = "createdAt"
        case updatedDate = "updatedAt"
        case workbooks
    }
}
