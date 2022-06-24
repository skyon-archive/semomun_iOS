//
//  WorkbookPreviewOfDB.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation

struct SearchWorkbookPreviews: Decodable, CustomStringConvertible {
    var description: String {
        return "\(count), \(workbooks)"
    }
    
    let count: Int
    let workbooks: [WorkbookPreviewOfDB]
}

struct WorkbookPreviewOfDB: Decodable {
    let wgid: Int? // new: workbookGroup 속한경우의 상위 wgid값
    let wid: Int //문제집 고유 번호
    let title: String
    let author: String //저자
    let publishedDate: Date //발행일
    let publishCompany: String //출판사
    let bookcover: UUID //문제집 표지 이미지 uuid
    let subject: String? //과목 이름
    let area: String? //영역 이름
    
    enum CodingKeys: String, CodingKey {
        case wgid, wid, title, author
        case publishedDate = "date"
        case publishCompany, bookcover
        case subject, area
    }
}

struct Cutoff: Codable {
    let rank: String
    let rawScore: Int
    let percentile: Int
}
