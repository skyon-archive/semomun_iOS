//
//  SaveSectionUsecase.swift
//  Semomoon
//
//  Created by qwer on 2021/11/21.
//

import Foundation

class SaveSectionUsecase {
    let section: Section_Core
    var pids: [Int] = []
    var totalScore: Int = 0
    var wrongProblems: [String] = []
    
    init(section: Section_Core) {
        self.section = section
    }
    
    func fetchPids() {
        let dumlicatedPids = section.dictionaryOfProblem.values.map() { $0 }
        let setPids = Set(dumlicatedPids)
        self.pids = Array(setPids).sorted(by: < )
    }
}
