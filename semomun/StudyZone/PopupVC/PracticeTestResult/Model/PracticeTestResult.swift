//
//  PracticeTestResult.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/06/21.
//

import Foundation

/// 로컬 정보
struct PracticeTestResult {
    let rawScore: Int
    let perfectScore: Int
    let correctProblemCount: Int
    let totalProblemCount: Int
    let totalTimeFormattedString: String
    let groupAverage: Int
    
    let rank: String
    let standardScore: Int
    let percentile: Int
    
    let subject: String
    let cutoff: [Cutoff]
}
