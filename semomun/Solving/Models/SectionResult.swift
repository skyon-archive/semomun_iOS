//
//  SectionResult.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation

struct SectionResult {
    let title: String
    let totalScore: Int
    let totalTime: Int64
    let wrongProblems: [String]
    
    init(title: String, totalScore: Int, totalTime: Int64, wrongProblems: [String]) {
        self.title = title
        self.totalScore = totalScore
        self.totalTime = totalTime
        self.wrongProblems = wrongProblems
    }
}
