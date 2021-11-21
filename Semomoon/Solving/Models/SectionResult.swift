//
//  SectionResult.swift
//  Semomoon
//
//  Created by qwer on 2021/11/21.
//

import Foundation

struct SectionResult {
    let pids: [Int]
    let totalScore: Int
    let wrongProblems: [String]
    
    init(pids: [Int], totalScore: Int, wrongProblems: [String]) {
        self.pids = pids
        self.totalScore = totalScore
        self.wrongProblems = wrongProblems
    }
}
