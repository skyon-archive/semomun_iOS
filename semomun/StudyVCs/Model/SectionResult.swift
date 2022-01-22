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
    
    init(title: String, totalTime: Int64, sectionUsecase: SaveSectionUsecase) {
        self.title = title
        self.totalTime = totalTime
        self.perfectScore = sectionUsecase.perfectScore
        self.totalScore = sectionUsecase.totalScore
        self.wrongProblems = sectionUsecase.wrongProblems
    }
}
