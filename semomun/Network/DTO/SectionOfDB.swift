//
//  SectionOfDB.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation

struct SectionOfDB: Codable {
    let wid: Int //속한 workbook 값
    let sid: Int //식별값
    let index: Int //섹션 번호
    let title: String //section 명
    let detail: String //section 설명
    let cutoff: Cutoff //json 형식의 커트라인
    let sectioncover: String //section 표시파일 uuid
    let size: Int //section 파일크기
    let audio: String? //음성파일 uuid
    let audioDetail: String? //json 형식의 음성 파일에 대한 timestamp 등의 값
    let createdAt: String //생성일자
    let updatedAt: String //반영일자
}

struct Cutoff: Codable {}
