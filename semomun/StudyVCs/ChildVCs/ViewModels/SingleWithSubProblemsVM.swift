//
//  SingleWithSubProblemsVM.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/05/26.
//

import Foundation

final class SingleWithSubProblemsVM: PageVM {
    override func answerStringForUser(_ problem: Problem_Core? = nil) -> String? {
        return problem?.answer
    }
    override func isCorrect(input: String, answer: String) -> Bool {
        return input == answer
    }
}
