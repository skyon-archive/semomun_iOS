//
//  Page.swift
//  Semomoon
//
//  Created by qwer on 2021/10/03.
//

import Foundation

struct PageOfDB: Codable, CustomStringConvertible {
    var description: String {
        return "View[\(vid), \(!(material?.isEmpty ?? true)), \(problems)]\n"
    }
    
    let vid: Int //뷰어의 고유 번호
    let index_start: Int //뷰어에 포함될 문제의 시작 인덱스
    let index_end: Int //뷰어에 포함될 문제의 끝 인덱스
    let material: String? //뷰어의 자료로 쓰일 이미지 정보
    let form: Int //0: 세로선 기준, 1: 가로선 기준 구분형태
    let record: String?
    let problems: [ProblemOfDB]
}
