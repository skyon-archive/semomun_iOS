//
//  PrivateTestResultOfDB.swift
//  semomun
//
//  Created by Kang Minsang on 2022/06/20.
//

import Foundation

struct PrivateTestResultOfDB: Decodable {
    let subject: String // 과목명
    let totalTime: Int // 총 소요 시간
    let rank: String // 등급
    let rawScore: Int // 원점수
    let standardScore: Int // 표준 점수
    let percentile: Int // 백분위
    let cutoff: [Cutoff]
    
    enum CodingKeys: String, CodingKey {
        case subject, totalTime, rank, rawScore, standardScore, percentile, cutoff
    }
}