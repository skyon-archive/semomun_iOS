//
//  PageData.swift
//  Semomoon
//
//  Created by Kang Minsang on 2021/10/24.
//

import Foundation
import CoreData

class PageData {
    let vid: Int
    var layoutType: String!
    var pageCore: Page_Core!
    var problems: [Problem_Core] = []
    
    init(vid: Int) {
        self.vid = vid
        self.fetchPageCore()
        self.configureProblems()
    }
    
    // 4. pageCore 로딩
    func fetchPageCore() {
        let fetchRequest: NSFetchRequest<Page_Core> = Page_Core.fetchRequest()
        let filter = NSPredicate(format: "vid = %@", "\(self.vid)")
        fetchRequest.predicate = filter
        
        if let fetches = try?
            CoreDataManager.shared.context.fetch(fetchRequest) {
            guard let pageData = fetches.first else { return }
            self.pageCore = pageData
            self.layoutType = pageData.layoutType
        }
    }
    
    // 5. page : problems 모두 로딩
    func configureProblems() {
        self.problems = Array(repeating: Problem_Core(), count: self.pageCore.problems.count)
        for (idx, pid) in self.pageCore.problems.enumerated() {
            self.fetchProblemCore(pid: pid) { problem in
                self.problems[idx] = problem
            }
        }
    }
    
    // 5. problem 로딩
    func fetchProblemCore(pid: Int, completion: @escaping(Problem_Core) -> Void) {
        let fetchRequest: NSFetchRequest<Problem_Core> = Problem_Core.fetchRequest()
        let filter = NSPredicate(format: "pid = %@", "\(pid)")
        fetchRequest.predicate = filter
        
        if let fetchs = try?
            CoreDataManager.shared.context.fetch(fetchRequest) {
            guard let problem = fetchs.first else { return }
            completion(problem)
        }
    }
}
