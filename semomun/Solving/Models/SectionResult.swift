//
//  SectionResult.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation

struct SectionResult {
    let title: String
    let perfectScore: Double
    let totalScore: Double
    let totalTime: Int64
    let wrongProblems: [String]
    
    init(title: String, perfectScore: Double, totalScore: Double, totalTime: Int64, wrongProblems: [String]) {
        self.title = title
        self.perfectScore = perfectScore
        self.totalScore = totalScore
        self.totalTime = totalTime
        self.wrongProblems = wrongProblems
    }
}
