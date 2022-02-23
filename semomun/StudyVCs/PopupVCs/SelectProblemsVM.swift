//
//  SelectProblemVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/02/23.
//

import Foundation
import Combine

final class SelectProblemsVM {
    @Published private(set) var title: String = ""
    @Published private(set) var problems: [Problem_Core] = []
    @Published private(set) var scoringQueue: [Int] = []
    private(set) var uploadQueue: [Int] = []
    private(set) var scoreableTotalCount: Int = 0
    private let section: Section_Core
    
    init(section: Section_Core) {
        self.section = section
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
    
    private func configureScoringQueue() {
        self.scoringQueue = self.section.scoringQueue ?? []
    }
    
    private func configureUploadQueue() {
        self.uploadQueue = self.section.uploadQueue ?? []
    }
    
    private func configureScoreableTotalCount() {
        self.scoreableTotalCount = self.problems.filter { !$0.terminated }.count
    }
    
    func isChecked(at index: Int) -> Bool {
        return self.scoringQueue.contains(Int(self.problems[index].pid))
    }
    
    func toggle(at index: Int) {
        if self.isChecked(at: index) {
            let targetPid = Int(self.problems[index].pid)
            guard let targetIndex = self.scoringQueue.firstIndex(of: targetPid) else { return }
            self.scoringQueue.remove(at: targetIndex)
        } else {
            let newPid = Int(self.problems[index].pid)
            self.scoringQueue.append(newPid)
        }
    }
    
    func selectAll(to allSelect: Bool) {
        if allSelect {
            self.configureAllPids()
        } else {
            self.scoringQueue = []
        }
    }
    
    private func configureAllPids() {
        self.scoringQueue = self.problems.filter { !$0.terminated }.map { Int($0.pid) }
    }
}
