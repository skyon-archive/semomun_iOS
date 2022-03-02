//
//  WorkbookOfDB.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation

struct WorkbookOfDB: Decodable {
    let productID: Int //상품 식별자
    let wid: Int //문제집 고유 번호
    let title: String
    let detail: String //문제집 정보
    let isbn: String //ISBN값
    let author: String //저자
    let publishedDate: Date //발행일
    let publishMan: String //발행인
    let publishCompany: String //출판사
    let originalPrice: String //정가
    let bookcover: String //문제집 표지 이미지 uuid
    let createdDate: Date //생성일자
    let updatedDate: Date //반영일자
    let sections: [SectionOfDB]
    let price: Int
    let tags: [TagOfDB]
    let sales: Int
    
    enum CodingKeys: String, CodingKey {
        case productID = "id"
        case wid, title, detail, isbn, author
        case publishedDate = "date"
        case publishMan, publishCompany, originalPrice, bookcover
        case createdDate = "createdAt"
        case updatedDate = "updatedAt"
        case sections, price, tags, sales
    }
}

struct TagOfDB: Decodable {
    let tid: Int
    let name: String
}
