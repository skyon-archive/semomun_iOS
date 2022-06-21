//
//  WorkbookPreviewOfDB.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation

struct SearchWorkbookPreviews: Decodable, CustomStringConvertible {
    var description: String {
        return "\(count), \(previews)"
    }
    
    let count: Int
    let previews: [WorkbookPreviewOfDB]
    
    enum CodingKeys: String, CodingKey {
        case count
        case previews = "workbooks"
    }
}

struct WorkbookPreviewOfDB: Decodable {
    let productID: Int //상품 식별자
    let wid: Int //문제집 고유 번호
    let title: String
    let detail: String //문제집 정보
    let isbn: String //ISBN값
    let author: String //저자
    let publishedDate: Date //발행일
    let publishMan: String //발행인
    let publishCompany: String //출판사
    let originalPrice: Int //정가
    let bookcover: UUID //문제집 표지 이미지 uuid
    let createdDate: Date //생성일자
    let updatedDate: Date //반영일자
    
    enum CodingKeys: String, CodingKey {
        case productID = "id"
        case wid, title, detail, isbn, author
        case publishedDate = "date"
        case publishMan, publishCompany, originalPrice, bookcover
        case createdDate = "createdAt"
        case updatedDate = "updatedAt"
    }
}
