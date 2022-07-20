//
//  SectionHeaderOfDB.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation

/// Note: WorkbookDetailVC 내에 섹션 정보를 저장해 보이기 위한 DTO
struct SectionHeaderOfDB: Decodable {
    let wid: Int //속한 workbook 값
    let sid: Int //식별값
    let sectionNum: Int //섹션 번호
    let title: String //section 명
    let detail: String //section 설명
    let sectioncover: String //section 표시파일 uuid, 사용X
    let fileSize: Int //section 파일크기
    let audio: String? //음성파일 uuid
    let audioDetail: String? //json 형식의 음성 파일에 대한 timestamp 등의 값
    let createdDate: Date //생성일자
    let updatedDate: Date //반영일자
    
    enum CodingKeys: String, CodingKey {
        case wid, sid
        case sectionNum = "index"
        case title, detail, sectioncover
        case fileSize = "size"
        case audio, audioDetail
        case createdDate = "createdAt"
        case updatedDate = "updatedAt"
    }
}
