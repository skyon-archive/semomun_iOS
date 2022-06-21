//
//  PracticeTestResult.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/06/21.
//

import Foundation

struct PracticeTestResult {
    /* public */
    let title: String
    let correctProblemCount: Int
    let totalProblemCount: Int
    let totalTimeFormattedString: String
    let privateScoreResult: ScoreResult
    let publicScoreResult: ScoreResult
}

struct ScoreResult {
    let rank: Int
    let rawScore: Int
    let deviation: Int
    let percentile: Int
    /// 총점 대비 맞은 점수의 비율
    let correctRatio: Double
    
    init(rank: Int, rawScore: Int, deviation: Int, percentile: Int, perfectScore: Int) {
        self.rank = rank
        self.rawScore = rawScore
        self.deviation = deviation
        self.percentile = percentile
        self.correctRatio = Double(rawScore) / Double(perfectScore)
    }
}
