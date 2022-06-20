//
//  TestResultInfoOfDB.swift
//  semomun
//
//  Created by Kang Minsang on 2022/06/20.
//

import Foundation

struct TestResultInfoOfDB: Decodable {
    let id: Int
    let wid: Int
    let wgid: Int
    let title: String // 회차 이름
    let detail: String
    let subject: String // 과목명
    let area: String // 영역명
    let cutoff: String // JSON 형식이라 한번 더 확인이 필요
    let sovingTime: Int
    let result: TestResultInfo
}

struct TestResultInfo: Decodable {
    let rank: Int // 등급
    let rawScore: Int // 원점수
    let deviation: Int // 표준 점수
    let percentile: Int // 백분위
}
