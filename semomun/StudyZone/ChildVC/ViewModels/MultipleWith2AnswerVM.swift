//
//  MultipleWith2AnswerVM.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation

final class MultipleWith2AnswerVM: PageVM {
    override func isCorrect(input: String, answer: String) -> Bool {
        return input == answer
    }
}
