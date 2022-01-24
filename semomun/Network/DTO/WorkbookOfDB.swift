//
//  WorkbookOfDB.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation

struct SearchWorkbook: Codable {
    var workbook: WorkbookOfDB
    var sections: [SectionOfDB]
}

struct WorkbookOfDB: Codable {
    var wid: Int //문제집 고유 번호
    var title: String
    var year: String //출판연도
    var month: String //출판 달
    var price: Int //가격(원)
    var detail: String //문제집 정보
    var bookcover: String //문제집 표지 이미지
    var sales: Int //문제집 판매량
    var publisher: String //문제집 출판사
    var category: String //문제집 유형
    var subject: String //문제집 주제
    var grade: String //학년
}