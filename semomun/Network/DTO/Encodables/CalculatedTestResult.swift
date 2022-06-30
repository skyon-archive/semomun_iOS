//
//  CalculatedTestResult.swift
//  semomun
//
//  Created by Kang Minsang on 2022/06/23.
//

import Foundation

struct CalculatedTestResult: Encodable {
    let wgid: Int // 종합성적표에서 filter 값
    let wid: Int
    let sid: Int // 보냄
    let rank: String // 등급
    let rawScore: Int // 원점수
    let perfectScore: Int // 만점 점수
    let deviation: Int // 표준 점수
    let percentile: Int // 백분위
    let correctProblemCount: Int // 맞은 개수 (웹 + 동기화를 위함)
    let totalProblemCount: Int // 전체 개수 (웹 + 동기화를 위함)
    let totalTime: Int // 시간
    let subject: String // 과목명
}
