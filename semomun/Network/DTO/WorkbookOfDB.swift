//
//  WorkbookOfDB.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation

struct SearchWorkbook: Codable {
    let workbook: WorkbookOfDB
    let sections: [SectionOfDB]
}

struct WorkbookOfDB: Codable {
    let id: Int //상품 식별자
    let wid: Int //문제집 고유 번호
    let title: String
    let detail: String //문제집 정보
    let isbn: String //ISBN값
    let author: String //저자
    let date: Date //발행일
    let publishMan: String //발행인
    let publishCompany: String //출판사
    let originalPrice: String //정가
    let bookcover: String //문제집 표지 이미지 uuid
    let createdAt: Date //생성일자
    let updatedAt: Date //반영일자
}
