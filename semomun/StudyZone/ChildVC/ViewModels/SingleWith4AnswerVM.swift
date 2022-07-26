//
//  SingleWith4AnswerVM.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation

final class SingleWith4AnswerVM: PageVM {
    /// 다답형 유무
    let shouldChooseMultipleAnswer: Bool
    
    /// CoreData에 저장된, 유저가 선택한 선지들
    var savedSolved: [String] {
        guard let solved = self.problem?.solved else { return [] }
        return solved
            .split(separator: ",")
            .compactMap { String($0) }
    }
    
    /// 문제의 정답.
    var answer: [String] {
        guard let answer = self.problem?.answer else { return [] }
        
        return answer.split(separator: ",").compactMap { String($0) }
    }
    
    override init(delegate: PageDelegate, pageData: PageData, mode: StudyVC.Mode?) {
        self.shouldChooseMultipleAnswer = (pageData.problems.first?.answer?.contains(",") == true)
        super.init(delegate: delegate, pageData: pageData, mode: mode)
    }
    
    override func answerStringForUser(_ problem: Problem_Core? = nil) -> String? {
        guard let answer = self.problem?.answer else { return nil }
        
        return answer
            .split(separator: ",")
            .joined(separator: ", ")
    }
    
    override func isCorrect(input: String, answer: String) -> Bool {
        return input == answer
    }
    
    func updateSolved(userAnswer: String, problem: Problem_Core? = nil) {
        if self.shouldChooseMultipleAnswer {
            var selectedAnswers = self.savedSolved
            if selectedAnswers.contains(userAnswer) == false {
                selectedAnswers.append(userAnswer)
            } else {
                selectedAnswers.removeAll(where: { $0 == userAnswer })
            }
            let answersConverted = selectedAnswers.sorted().joined(separator: ",")
            self.updateSolved(withSelectedAnswer: answersConverted, problem: problem)
        } else {
            self.updateSolved(withSelectedAnswer: userAnswer, problem: problem)
        }
    }
}
