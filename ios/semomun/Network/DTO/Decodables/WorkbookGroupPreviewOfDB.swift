//
//  WorkbookGroupPreviewOfDB.swift
//  semomun
//
//  Created by Kang Minsang on 2022/06/20.
//

import Foundation

struct SearchWorkbookGroups: Decodable {
    let count: Int
    let workbookGroups: [WorkbookGroupPreviewOfDB]
}

struct WorkbookGroupPreviewOfDB: Decodable {
    let wgid: Int
    let itemID: Int?
    let type: String
    let title: String
    let detail: String // 현재로썬 안쓰이는 값, 빈배열로 수신
    let groupCover: UUID
    let isGroupOnlyPurchasable: Bool // 전체구매만 가능한지 여부
    let createdDate: Date
    let updatedDate: Date
    
    enum CodingKeys: String, CodingKey {
        case wgid
        case itemID = "id"
        case type, title, detail, groupCover, isGroupOnlyPurchasable
        case createdDate = "createdAt"
        case updatedDate = "updatedAt"
    }
    
    var info: WorkbookGroupInfo {
        return WorkbookGroupInfo(wgid: self.wgid, title: self.title)
    }
}

extension WorkbookGroupPreviewOfDB: HomeBookcoverCellInfo {
    var workbookDetailInfo: (wid: Int?, workbookGroupPreviewOfDB: WorkbookGroupPreviewOfDB?) {
        return (nil, self)
    }
    
    var publishCompany: String {
        return "실전 모의고사"
    }
    
    var bookcover: UUID {
        return self.groupCover
    }
}