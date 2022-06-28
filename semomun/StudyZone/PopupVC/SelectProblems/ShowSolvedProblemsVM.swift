//
//  ShowSolvedProblemsVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/06/28.
//

import Foundation
import Combine

final class ShowSolvedProblemsVM {
    @Published private(set) var title: String = ""
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
    
    private func configureTitle() {
        self.title = self.section.title ?? ""
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
    
    func startScoring(completion: @escaping (Bool) -> Void) {
        // 모든 Problem -> terminate 처리
        self.problems.forEach { problem in
            problem.setValue(true, forKey: Problem_Core.Attribute.terminated.rawValue)
        }
        // scoringQueue = []
        self.section.setValue([], forKey: PracticeTestSection_Core.Attribute.scoringQueue.rawValue)
        // section.terminated
        NotificationCenter.default.post(name: .sectionTerminated, object: nil)
        // save section, VC: dismiss action
        CoreDataManager.saveCoreData()
        completion(true)
    }
}
