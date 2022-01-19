//
//  SaveSectionUsecase.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation
import CoreData

class SaveSectionUsecase {
    private let section: Section_Core
    private var vids: [Int] = []
    private(set) var perfectScore: Double = 0
    private(set) var totalScore: Double = 0
    private(set) var wrongs: [Bool] = []
    private(set) var wrongProblems: [String] = []
    private(set) var submissions: [Submission] = []
    
    init(section: Section_Core) {
        self.section = section
        self.fetchVids()
        self.calculateSectionResult()
    }
    
    private func fetchVids() {
        let dumlicatedVids = section.dictionaryOfProblem.values.map() { $0 }
        self.vids = Array(Set(dumlicatedVids)).sorted(by: < )
    }
    
    private func calculateSectionResult() {
        self.vids.forEach { vid in
            self.calculateProblems(vid: vid)
        }
    }
    
    private func calculateProblems(vid: Int) {
        guard let page = CoreUsecase.fetchPage(vid: vid) else { return }
        page.problems.forEach { pid in
            guard let problem = CoreUsecase.fetchProblem(pid: pid) else { return }
            problem.setValue(true, forKey: "terminated")
            
            let submission = Submission(problem: problem)
            self.submissions.append(submission)
            
            // 원점수 합산, 틀린문제 합산
            if let correct = submission.correct,
               let pName = problem.pName {
                self.perfectScore += problem.point
                self.wrongs.append(correct != 1)
                
                if correct == 0 {
                    self.wrongProblems.append(pName)
                } else {
                    self.totalScore += problem.point
                }
            } else {
                self.wrongs.append(false)
            }
        }
    }
}
