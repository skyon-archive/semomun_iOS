//
//  MultipleWith2AnswerWideVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/27.
//

import Foundation

final class MultipleWith2AnswerWideVM: PageVM {
    override func isCorrect(input: String, answer: String) -> Bool {
        return input == answer
    }
}
