//
//  SingleWith5AnswerViewModel.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation

final class SingleWith5AnswerVM: PageVM {
    override init(delegate: PageDelegate, pageData: PageData) {
        self.shouldChooseMultipleAnswer = (pageData.problems.first?.answer?.contains(",") == true)
        super.init(delegate: delegate, pageData: pageData)
    }
    
    override func answer(of problem: Problem_Core? = nil) -> String? {
        guard let answer = self.problem?.answer else { return nil }
        if answer.contains("|") {
            return "복수"
        } else {
            return answer
        }
    }
    
    override func isCorrect(input: String, answer: String) -> Bool {
        let answers = answer.split(separator: "|").map { String($0) }
        return answers.contains(input)
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
    
    /// 다답형 유무
    let shouldChooseMultipleAnswer: Bool
    
    /// CoreData에 저장된, 유저가 선택한 선지들
    var savedSolved: [Int] {
        guard let solved = self.problem?.solved else { return [] }
        return solved
            .split(separator: ",")
            .compactMap { Int($0) }
            .map { $0 - 1}
    }
    
    /// 문제의 정답. 복수 답안일 경우 제일 처음 것만 반환
    var answer: [Int] {
        guard let answer = self.problem?.answer else { return [] }
        
        let answers = answer.split(separator: "|").map { String($0) }
        guard let firstAnswer = answers.first else { return [] }
        return firstAnswer.split(separator: ",").compactMap { Int($0) }
    }
}
