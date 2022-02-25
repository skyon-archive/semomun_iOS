//
//  SectionResult.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation

struct SectionResult {
    let perfectScore: Double
    let score: Double
    let time: Int64
    let wrongProblems: [String]
    
    init(perfactScore: Double, score: Double, time: Int64, wrongProblems: [String]) {
        self.time = time
        self.perfectScore = perfactScore
        self.score = score
        self.wrongProblems = wrongProblems
    }
}
