//
//  SectionOfDB.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation

struct SectionOfDB: Decodable, CustomStringConvertible {
    var description: String {
        return "Section(\(sid))\n" + pages.map(\.description).joined(separator: "\n")
    }
    
    let wid: Int //속한 workbook 값
    let sid: Int //식별값
    let sectionNum: Int //섹션 번호
    let title: String //section 명
    let detail: String //section 설명
    let sectioncover: UUID //section 표시파일 uuid, 사용X
    let fileSize: Int //section 파일크기
    let audio: String? //음성파일 uuid
    let audioDetail: String? //json 형식의 음성 파일에 대한 timestamp 등의 값
    let createdDate: Date //생성일자
    let updatedDate: Date //반영일자
    let pages: [PageOfDB]
    
    enum CodingKeys: String, CodingKey {
        case wid, sid
        case sectionNum = "index"
        case title, detail, sectioncover
        case fileSize = "size"
        case audio, audioDetail
        case createdDate = "createdAt"
        case updatedDate = "updatedAt"
        case pages = "views"
    }
}

struct PageOfDB: Decodable, CustomStringConvertible {
    var description: String {
        return "Page(\(vid)) \(problems)"
    }
    
    let sid: Int
    let vid: Int //페이지 고유 번호
    let index: Int //페이지 번호
    let form: Int //페이지 유형
    let material: UUID? //지문 이미지 uuid
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
