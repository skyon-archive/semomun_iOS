//
//  SingleWith5AnswerViewModel.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation

final class SingleWith5AnswerVM: PageVM<String> {
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
}
