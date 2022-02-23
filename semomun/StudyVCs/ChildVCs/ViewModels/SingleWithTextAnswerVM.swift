//
//  SingleWithTextAnswerViewModel.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation

final class SingleWithTextAnswerVM: PageVM {
    override func answer(of problem: Problem_Core? = nil) -> String? {
        return problem?.answer
    }
    override func isCorrect(input: String, answer: String) -> Bool {
        return input == answer
    }
}
