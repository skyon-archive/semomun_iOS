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
        self.uploadQueue = self.section.uploadProblemQueue ?? []
        print("upload: \(self.uploadQueue)")
    }
    
    private func configureScoreableTotalCount() {
        self.scoreableTotalCount = self.problems.filter { !$0.terminated }.count
    }
    
    func isChecked(at index: Int) -> Bool {
        return self.scoringQueue.contains(Int(self.problems[index].pid))
    }
    
    func toggle(at index: Int) {
        guard self.problems[index].terminated == false else { return }
        
        if self.isChecked(at: index) {
            let targetPid = Int(self.problems[index].pid)
            guard let targetIndex = self.scoringQueue.firstIndex(of: targetPid) else { return }
            self.scoringQueue.remove(at: targetIndex)
        } else {
            let newPid = Int(self.problems[index].pid)
            self.scoringQueue.append(newPid)
            
            if self.uploadQueue.contains(newPid) { return }
            self.uploadQueue.append(newPid)
        }
    }
    
    func selectAll(to allSelect: Bool) {
        if allSelect {
            self.configureAllPids()
        } else {
            self.scoringQueue = []
        }
    }
    
    func startScoring(completion: @escaping (Bool) -> Void) {
        // scoringQueue 모든 Problem -> terminate 처리
        self.problems.filter { self.scoringQueue.contains(Int($0.pid)) }.forEach { problem in
            problem.setValue(true, forKey: "terminated")
        }
        // scoringQueue = []
        self.section.setValue([], forKey: "scoringQueue")
        // uploadQueue -> setValue 처리
        self.section.setValue(self.uploadQueue, forKey: Section_Core.Attribute.uploadProblemQueue.rawValue)
        // count == totalCount -> section.terminated
        if scoringQueue.count == self.scoreableTotalCount {
            NotificationCenter.default.post(name: .sectionTerminated, object: nil)
        }
        // save section, VC: dismiss action
        CoreDataManager.saveCoreData()
        completion(true)
    }
    
    private func configureAllPids() {
        self.scoringQueue = self.problems.filter { !$0.terminated }.map { Int($0.pid) }
    }
}
