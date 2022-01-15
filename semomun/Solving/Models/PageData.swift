//
//  PageData.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation
import CoreData

final class PageData {
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
    private func fetchPageCore() {
        if let pageData = CoreUsecase.fetchPage(vid: self.vid) {
            self.pageCore = pageData
            self.layoutType = pageData.layoutType
        }
    }
    
    // 5. page : problems 모두 로딩
    private func configureProblems() {
        for pid in self.pageCore.problems {
            if let problemCore = CoreUsecase.fetchProblem(pid: pid) {
                self.problems.append(problemCore)
            }
        }
    }
}
