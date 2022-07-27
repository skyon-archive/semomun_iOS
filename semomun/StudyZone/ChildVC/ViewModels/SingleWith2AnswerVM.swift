//
//  SingleWith2AnswerVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/27.
//

final class SingleWith2AnswerVM: PageVM {
    override func isCorrect(input: String, answer: String) -> Bool {
        return input == answer
    }
    
    func updateSolved(userAnswer: String) {
        guard let problem = self.problem else { return }
        self.updateSolved(withSelectedAnswer: userAnswer, problem: problem)
    }
}
