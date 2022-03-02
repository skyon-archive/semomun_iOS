//
//  SectionOfDB.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation

struct SectionOfDB: Codable, CustomStringConvertible {
    var description: String {
        return "Section(\(sid)) \(pages)"
    }
    
    let sid: Int
    let updatedDate: Date
    let pages: [PageOfDB]
    
    enum CodingKeys: String, CodingKey {
        case sid
        case updatedDate = "updatedAt"
        case pages = "views"
    }
}

struct PageOfDB: Codable, CustomStringConvertible {
    var description: String {
        return "\nPage(\(vid)) \(problems)\n"
    }
    
    let sid: Int
    let vid: Int //페이지 고유 번호
    let index: Int //페이지 번호
    let form: Int //페이지 유형
    let material: String? //지문 이미지 uuid
    let attachment: String? //추후 있을 화면단위 동영상 등의 자료 uuid
    let problems: [ProblemOfDB]
    let updatedDate: Date
    
    enum CodingKeys: String, CodingKey {
        case sid, vid, index, form
        case material = "passage"
        case attachment, problems
        case updatedDate = "updatedAt"
    }
}
