//
//  SectionResultVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/02/25.
//

import Foundation
import Combine

final class SectionResultVM {
    @Published private(set) var sectionTitle: String?
    @Published private(set) var result: SectionResult?
    private let section: Section_Core
    private var perfectScore: Double = 0
    private var score: Double = 0
    private var time: Int64 = 0
    private var wrongProblems: [String] = []
    
    init(section: Section_Core) {
        self.section = section
    }
    
    func calculateResult() {
        self.sectionTitle = self.section.title
        let problems = self.section.problemCores?
            .sorted(by: { $0.orderIndex < $1.orderIndex}) ?? []
        
        problems.filter { $0.terminated }.forEach { problem in
            // 문제 배점 누적
            self.perfectScore += problem.point
            // 문제 걸린시간 누적
            self.time += problem.time
            // 맞은경우 -> true 저장, score 누적
            if problem.correct {
                self.score += problem.point
            } else if problem.subProblemsCount > 0 {
                self.score += Double(problem.correctPoints)
            }
            // 틀린경우 -> false 저장, wrongProblems 누적
            else {
                self.wrongProblems.append(problem.pName ?? "-")
            }
            // 채점 불가한 경우 -> ?
        }
        
        self.result = SectionResult(perfectScore: self.perfectScore, score: self.score, time: self.time, wrongProblems: self.wrongProblems)
    }
}
