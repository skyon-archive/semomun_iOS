//
//  Section.swift
//  Semomoon
//
//  Created by qwer on 2021/10/03.
//

import Foundation

struct SectionOfDB: Codable {
    let sid: Int // 식별값
    let wid: Int
    let index: Int
    let title: String // 문제집 이름
    let detail: String? // json 형식의 문제집 설명내용
    let image: String // 문제집 표지
    let cutoff: String? // json 형식의 커트라인
    
    enum CodingKeys: String, CodingKey {
        case sid, wid, index, title, detail
        case image = "sectioncover"
        case cutoff
    }
}
