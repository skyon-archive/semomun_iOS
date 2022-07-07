//
//  WorkbookGroupCellInfo.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/07.
//

import Foundation

struct WorkbookGroupCellInfo {
    let wgid: Int
    let title: String
    let publisher: String
    let imageData: Data?
    let recentDate: Date?
    let purchasedDate: Date?
    
    init(core: WorkbookGroup_Core) {
        self.wgid = Int(core.wgid)
        self.title = core.title ?? "제목 없음"
        self.publisher = "실전 모의고사"
        self.imageData = core.image
        self.recentDate = core.recentDate
        self.purchasedDate = core.purchasedDate
    }
}
