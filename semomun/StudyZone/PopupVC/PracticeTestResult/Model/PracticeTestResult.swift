//
//  PracticeTestResult.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/06/21.
//

import Foundation

struct PracticeTestResult {
    /* public */
    let rawScore: Int
    let correctProblemCount: Int
    let totalProblemCount: Int
    let totalTimeFormattedString: String
    let groupAverage: Int
    let privateScoreResult: ScoreResult
    let subject: String
}
