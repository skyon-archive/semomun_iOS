//
//  SaveSectionUsecase.swift
//  Semomoon
//
//  Created by qwer on 2021/11/21.
//

import Foundation
import CoreData

class SaveSectionUsecase {
    let section: Section_Core
    var vids: [Int] = []
    var totalScore: Int = 0
    var wrongProblems: [String] = []
    var submissions: [Submission] = []
    
    init(section: Section_Core) {
        self.section = section
    }
    
    func fetchPids() {
        let dumlicatedVids = section.dictionaryOfProblem.values.map() { $0 }
        self.vids = Array(Set(dumlicatedVids)).sorted(by: < )
    }
    
    func calculateSectionResult() {
        self.vids.forEach { vid in
            self.calculateProblems(vid: vid)
        }
    }
    
    func fetchPageCore(vid: Int) -> Page_Core? {
        let fetchRequest: NSFetchRequest<Page_Core> = Page_Core.fetchRequest()
        let filter = NSPredicate(format: "vid = %@", "\(vid)")
        fetchRequest.predicate = filter
        
        if let fetches = try?
            CoreDataManager.shared.context.fetch(fetchRequest) {
            guard let page = fetches.first else { return nil }
            return page
        } else {
            return nil
        }
    }
    
    func fetchProblemCore(pid: Int) -> Problem_Core? {
        let fetchRequest: NSFetchRequest<Problem_Core> = Problem_Core.fetchRequest()
        let filter = NSPredicate(format: "pid = %@", "\(pid)")
        fetchRequest.predicate = filter
        
        if let fetches = try?
            CoreDataManager.shared.context.fetch(fetchRequest) {
            guard let problem = fetches.first else { return nil }
            // problem : terminated 설정
            problem.setValue(true, forKey: "terminated")
            return problem
        } else {
            return nil
        }
    }
    
    func calculateProblems(vid: Int) {
        guard let page = self.fetchPageCore(vid: vid) else { return }
        page.problems.forEach { pid in
            guard let problem = self.fetchProblemCore(pid: pid) else { return }
            let submission = Submission(problem: problem)
            self.submissions.append(submission)
            // 원점수 합산, 틀린문제 합산
            
            if let correct = submission.correct,
               let pName = problem.pName {
                if correct == 0 {
                    self.wrongProblems.append(pName)
                } else {
                    self.totalScore += Int(problem.point)
                }
            } else {
                self.totalScore += Int(problem.point)
            }
        }
    }
}
