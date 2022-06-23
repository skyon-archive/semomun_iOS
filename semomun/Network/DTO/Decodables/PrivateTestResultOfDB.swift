//
//  PrivateTestResultOfDB.swift
//  semomun
//
//  Created by Kang Minsang on 2022/06/20.
//

import Foundation

struct PrivateTestResultOfDB: Decodable {
    let title: String // 회차 이름
    let subject: String // 과목명
    let area: String // 영역명
    
    let totalTime: Int // 총 소요 시간
    
    let rank: Int // 등급
    let rawScore: Int // 원점수
    let deviation: Int // 표준 점수
    let percentile: Int // 백분위
    
    enum CodingKeys: String, CodingKey {
        case title, subject, area, totalTime, rank, rawScore, deviation, percentile
    }
}
