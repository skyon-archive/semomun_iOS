//
//  SelectProblemVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/02/23.
//

import Foundation
import Combine

final class SelectProblemsVM {
    @Published private(set) var workbookTitle: String = ""
    @Published private(set) var sectionNum: Int = 0
    @Published private(set) var sectionTitle: String = ""
    @Published private(set) var scoringQueue: [Int] = []
    @Published private(set) var scoreableTotalCount: Int = 0
    @Published private(set) var showPastResult: Bool = false
    private let section: Section_Core
    private(set) var problems: [Problem_Core] = []
    private(set) var isScoring: Bool = false
    private(set) var uploadQueue: [Int] = []
    
    init(section: Section_Core, sectionNum: Int, workbookTitle: String) {
        self.workbookTitle = workbookTitle
        self.sectionNum = sectionNum
        self.sectionTitle = section.title ?? ""
        self.section = section
        self.configureProblems()
        self.configureScoringQueue()
        self.configureUploadQueue()
        self.configureScoreableTotalCount()
        self.configureShowPastResult()
    }
}

// MARK: Public
extension SelectProblemsVM {
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
    /// 선택한 문제 채점
    func startSelectedScoring(completion: @escaping (Bool) -> Void) {
        self.isScoring = true
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
    /// 전체 채점
    func startAllScoring(completion: @escaping (Bool) -> Void) {
        self.isScoring = true
        self.configureAllPids()
        self.startSelectedScoring(completion: completion)
    }
}

// MARK: Private
extension SelectProblemsVM {
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
    
    private func configureAllPids() {
        self.scoringQueue = self.problems.filter { !$0.terminated }.map { Int($0.pid) }
    }
    
    private func configureShowPastResult() {
        self.showPastResult = self.problems.count != self.scoreableTotalCount
    }
}
