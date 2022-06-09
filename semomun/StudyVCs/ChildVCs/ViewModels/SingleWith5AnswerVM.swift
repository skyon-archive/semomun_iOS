//
//  SingleWith5AnswerVM.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation

final class SingleWith5AnswerVM: PageVM {
    /// 다답형 유무
    let shouldChooseMultipleAnswer: Bool
    
    /// CoreData에 저장된, 유저가 선택한 선지들
    var savedSolved: [Int] {
        guard let solved = self.problem?.solved else { return [] }
        return solved
            .split(separator: ",")
            .compactMap { Int($0) }
    }
    
    /// 문제의 정답.a
    var answer: [Int] {
        guard let answer = self.problem?.answer else { return [] }
        
        return answer.split(separator: ",").compactMap { Int($0) }
    }
    
    override init(delegate: PageDelegate, pageData: PageData) {
        self.shouldChooseMultipleAnswer = (pageData.problems.first?.answer?.contains(",") == true)
        super.init(delegate: delegate, pageData: pageData)
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
    
    func updateSolved(withSelectedAnswers selectedAnswers: [Int], problem: Problem_Core? = nil) {
        if self.shouldChooseMultipleAnswer {
            let answersConverted = selectedAnswers.sorted().map { String($0) }.joined(separator: ",")
            self.updateSolved(withSelectedAnswer: answersConverted, problem: problem)
        } else {
            if let selectedAnswer = selectedAnswers.first {
                self.updateSolved(withSelectedAnswer: String(selectedAnswer), problem: problem)
            }
        }
    }
}
