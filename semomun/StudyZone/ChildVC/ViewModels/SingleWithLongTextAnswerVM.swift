//
//  SingleWithLongTextAnswerVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/27.
//

final class SingleWithLongTextAnswerVM: PageVM {
    override func answerStringForUser(_ problem: Problem_Core? = nil) -> String? {
        let problem = problem ?? self.problem
        return problem?.answer
    }
    
    override func isCorrect(input: String, answer: String) -> Bool {
        return true
    }
    
    func updateSolved(answer: String) {
        guard let problem = self.problem else { return }
        self.updateSolved(withSelectedAnswer: answer, problem: problem)
    }
}
