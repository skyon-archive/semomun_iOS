//
//  SingleWithSubProblemsVM.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/05/26.
//

import Foundation
import Combine

final class SingleWithSubProblemsVM: PageVM {
    @Published private(set) var userAnswers: [String?] = []
    let resultAnswers: [String]
    
    /// 아무 문제도 풀지 않았으면 true
    var noProblemSolved: Bool {
        return userAnswers.allSatisfy { $0 == nil }
    }
    
    override init(delegate: PageDelegate, pageData: PageData, mode: StudyVC.Mode?) {
        if let answer = pageData.problems.first?.answer {
            self.resultAnswers = answer.components(separatedBy: "$").map { String($0) }
        } else {
            self.resultAnswers = []
        }
        
        super.init(delegate: delegate, pageData: pageData, mode: mode)
        
        if let savedSolved = self.problem?.solved {
            self.userAnswers = savedSolved
                .components(separatedBy: "$")
                .map { $0 == "" ? nil : String($0) }
        } else {
            if let subProblemCount = self.problem?.subProblemsCount {
                self.userAnswers = Array(repeating: nil, count: Int(subProblemCount))
            }
        }
    }
    
    override func answerStringForUser(_ problem: Problem_Core? = nil) -> String? {
        guard let answer = self.problem?.answer else { return nil }
        
        return answer.components(separatedBy: "$").joined(separator: ", ")
    }
    
    override func isCorrect(input: String, answer: String) -> Bool {
        return input == answer
    }
    
    func changeUserAnswer(at index: Int, to newAnswer: String?) {
        guard self.userAnswers.indices.contains(index) else {
            assertionFailure()
            return
        }
        self.userAnswers[index] = newAnswer == "" ? nil : newAnswer
        self.updateSolved()
    }
    
    private func updateSolved() {
        let answerConverted = userAnswers.map({$0 ?? ""}).joined(separator: "$")
        self.updateSolved(withSelectedAnswer: answerConverted)
        self.updateCorrectPoints()
    }
    
    private func updateCorrectPoints() {
        let points = zip(userAnswers, resultAnswers)
            .filter { $0 == $1 }
            .count
        self.problem?.setValue(Int64(points), forKey: Problem_Core.Attribute.correctPoints.rawValue)
    }
}
