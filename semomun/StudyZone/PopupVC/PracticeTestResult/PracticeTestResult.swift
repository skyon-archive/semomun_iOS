//
//  PracticeTestResult.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/06/21.
//

import Foundation

/// PracticeTestResultVM가 VC로 전달하는 모델
struct PracticeTestResult {
    /* public */
    let privateScoreResult: ScoreResult
    let publicScoreResult: ScoreResult
    let correctProblemCount: Int
    let totalProblemCount: Int
    let totalTimeFormattedString: String
    /* private */
    
    init(privateTestResultOfDB: PrivateTestResultOfDB, publicTestResultOfDB: PublicTestResultOfDB) {
        let perfectScore = privateTestResultOfDB.perfectScore
        
        self.privateScoreResult = .init(
            rank: privateTestResultOfDB.rank,
            rawScore: privateTestResultOfDB.rawScore,
            deviation: privateTestResultOfDB.deviation,
            percentile: privateTestResultOfDB.percentile,
            perfectScore: perfectScore
        )
        
        self.publicScoreResult = .init(
            rank: publicTestResultOfDB.rank,
            rawScore: publicTestResultOfDB.rawScore,
            deviation: publicTestResultOfDB.deviation,
            percentile: publicTestResultOfDB.percentile,
            perfectScore: perfectScore
        )
        
        self.correctProblemCount = privateTestResultOfDB.correctProblemCount
        self.totalProblemCount = privateTestResultOfDB.totalProblemCount
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        self.totalTimeFormattedString = formatter.string(from: TimeInterval(privateTestResultOfDB.totalTime)) ?? "00-00-00"
    }
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
