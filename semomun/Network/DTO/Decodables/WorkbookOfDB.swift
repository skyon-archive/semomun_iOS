//
//  WorkbookOfDB.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation

struct WorkbookOfDB: Decodable {
    let productID: Int //상품 식별자
    let wgid: Int? // new: workbookGroup 속한경우의 상위 wgid값
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
    let sections: [SectionHeaderOfDB]
    let price: Int = 0
    let tags: [TagOfDB] = []
    let sales: Int = 0
    /* 실전 모의고사용 추가 property들 */
    let cutoff: [Cutoff]? = []//등급계산을 위한 데이터
    let subject: String //과목 이름
    let area: String //영역 이름
    let standardDeviation: Int? //표준 편차
    let averageScore: Int? //평균 점수
    let timelimit: Int? //제한시간
    
    enum CodingKeys: String, CodingKey {
        case productID = "id"
        case wgid, wid, title, detail, isbn, author
        case publishedDate = "date"
        case publishMan, publishCompany, bookcover
        case originalPrice = "paperbookPrice"
        case createdDate = "createdAt"
        case updatedDate = "updatedAt"
        case sections, price, tags, sales
        case cutoff, subject, area
        case standardDeviation, averageScore, timelimit
    }
}
