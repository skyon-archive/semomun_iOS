//
//  ScoreResult.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/06/21.
//

import Foundation

struct ScoreResult {
    let rank: Int
    let rawScore: Int
    let standardScore: Int
    let percentile: Int
    /// 총점 대비 맞은 점수의 비율
    let correctRatio: Double
    
    init(rank: Int, rawScore: Int, standardScore: Int, percentile: Int, perfectScore: Int) {
        self.rank = rank
        self.rawScore = rawScore
        self.standardScore = standardScore
        self.percentile = percentile
        self.correctRatio = Double(rawScore) / Double(perfectScore)
    }
}
