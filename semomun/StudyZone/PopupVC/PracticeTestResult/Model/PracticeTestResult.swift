//
//  PracticeTestResult.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/06/21.
//

import Foundation

/// PracticeTestResultVM에서 VC로 published를 통해 전달되는 정보의 집합
struct PracticeTestResult {
    let rawScore: Int
    let perfectScore: Int
    let correctProblemCount: Int
    let totalProblemCount: Int
    let totalTimeFormattedString: String
    let groupAverage: Int
    let privateScoreResult: ScoreResult
    let subject: String
    let cutoff: [Cutoff]
}
