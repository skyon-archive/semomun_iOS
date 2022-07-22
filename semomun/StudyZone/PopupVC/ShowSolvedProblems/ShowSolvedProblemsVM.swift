//
//  ShowSolvedProblemsVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/06/28.
//

import Foundation
import Combine

final class ShowSolvedProblemsVM {
    @Published private(set) var sectionTitle: String = ""
    @Published private(set) var problems: [Problem_Core] = []
    @Published private(set) var scoringQueue: [Int] = [] // 푼문제
    private(set) var uploadQueue: [Int] = [] // 건드린 문제
    private(set) var scoreableTotalCount: Int = 0
    private let section: PracticeTestSection_Core
    
    init(practiceSection: PracticeTestSection_Core) {
        self.section = practiceSection
        self.configureTitle()
        self.configureProblems()
        self.configureScoringQueue()
        self.configureUploadQueue()
        self.configureScoreableTotalCount()
    }
}

// MARK: Public
extension ShowSolvedProblemsVM {
    func isSolved(at index: Int) -> Bool {
        return self.scoringQueue.contains(Int(self.problems[index].pid))
    }
}

// MARK: Private
extension ShowSolvedProblemsVM {
    private func configureTitle() {
        self.sectionTitle = self.section.title ?? ""
    }
    
    private func configureProblems() {
        self.problems = self.section.problemCores?.sorted(by: { $0.orderIndex < $1.orderIndex}) ?? []
    }
    
    /// 푼문제 확인
    private func configureScoringQueue() {
        self.scoringQueue = self.section.scoringQueue ?? []
    }
    
    private func configureUploadQueue() {
        self.uploadQueue = self.section.uploadProblemQueue ?? []
    }
    
    private func configureScoreableTotalCount() {
        self.scoreableTotalCount = self.problems.count
    }
}
