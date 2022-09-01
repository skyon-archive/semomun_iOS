//
//  SingleWithSubProblemsVM.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/05/26.
//

import Foundation
import Combine

final class SingleWithSubProblemsVM: PageVM {
    override init(delegate: PageDelegate, pageData: PageData) {
        super.init(delegate: delegate, pageData: pageData)
    }
    
    override func isCorrect(input: String, answer: String) -> Bool {
        return input == answer
    }
    
    override func answerStringForUser(_ problem: Problem_Core? = nil) -> String? {
        guard let answer = self.problem?.answer else { return nil }
        
        return answer.components(separatedBy: "$").joined(separator: ", ")
    }
    
    func updateSolved(userAnswer: String, correctCount: Int) {
        guard let problem = self.problem else { return }
        self.updateSolved(withSelectedAnswer: userAnswer, problem: problem)
        self.problem?.setValue(Int64(correctCount), forKey: Problem_Core.Attribute.correctPoints.rawValue)
    }
}
