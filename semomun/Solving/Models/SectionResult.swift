//
//  SectionResult.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation

struct SectionResult {
    let title: String
    let perfectScore: Int
    let totalScore: Int
    let totalTime: Int64
    let wrongProblems: [String]
    
    init(title: String, perfectScore: Int, totalScore: Int, totalTime: Int64, wrongProblems: [String]) {
        self.title = title
        self.perfectScore = perfectScore
        self.totalScore = totalScore
        self.totalTime = totalTime
        self.wrongProblems = wrongProblems
    }
}
