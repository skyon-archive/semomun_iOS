//
//  SelectProblemVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/02/23.
//

import Foundation
import Combine

final class SelectProblemVM {
    @Published private(set) var title: String = ""
    @Published private(set) var problems: [Problem_Core] = []
    @Published private(set) var scoringQueue: [Int] = []
    private(set) var uploadQueue: [Int] = []
    private let section: Section_Core
    
    init(section: Section_Core) {
        self.section = section
        self.configureProblems()
        self.configureScoringQueue()
        self.configureUploadQueue()
    }
    
    private func configureProblems() {
        self.problems = self.section.problemCores?.sorted(by: { $0.orderIndex < $1.orderIndex}) ?? []
    }
    
    private func configureScoringQueue() {
        
    }
    
    private func configureUploadQueue() {
        
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
}
