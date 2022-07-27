//
//  MultipleWithSubProblemsVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/05/20.
//

import Foundation

final class MultipleWithSubProblemsVM: PageVM {
    override func isCorrect(input: String, answer: String) -> Bool {
        return input == answer
    }
}
