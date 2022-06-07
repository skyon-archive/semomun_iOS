//
//  SingleWithSubProblemsVM.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/05/26.
//

import Foundation

final class SingleWithSubProblemsVM: PageVM {
    /// 문제의 정답.
    var answer: [String] {
        guard let answer = self.problem?.answer else { return [] }
        
        return answer.split(separator: ",").map { String($0) }
    }
    
    override init(delegate: PageDelegate, pageData: PageData) {
        super.init(delegate: delegate, pageData: pageData)
    }
    
    override func answerStringForUser(_ problem: Problem_Core? = nil) -> String? {
        guard let answer = self.problem?.answer else { return nil }
        
        return answer.split(separator: "$").joined(separator: ", ")
    }
    
    override func isCorrect(input: String, answer: String) -> Bool {
        return input == answer
    }
    
    func updateSolved(withSelectedAnswer selectedAnswer: [String?]) {
        guard selectedAnswer.count == self.answer.count else {
            assertionFailure()
            return
        }
        
        let answerConverted = selectedAnswer.map({$0 ?? ""}).joined(separator: "$")
        self.updateSolved(withSelectedAnswer: answerConverted)
    }
}
