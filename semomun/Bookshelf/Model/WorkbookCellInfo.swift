//
//  WorkbookCellInfo.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/07.
//

import Foundation

struct WorkbookCellInfo {
    let wid: Int
    let title: String
    let publisher: String
    let imageData: Data?
    let recentDate: Date?
    let purchasedDate: Date?
    let tags: [String]

    init(core: Preview_Core) {
        self.wid = Int(core.wid)
        self.title = core.title ?? "제목 없음"
        self.publisher = core.publisher ?? "출판사 정보 없음"
        self.imageData = core.image
        self.recentDate = core.recentDate
        self.purchasedDate = core.purchasedDate
        self.tags = core.tags
    }
}
