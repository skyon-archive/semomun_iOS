//
//  MultipleWithShortTextAnswerVM.swift
//  semomun
//
//  Created by 스카이온 on 2022/07/27.
//

import Foundation

final class MultipleWithShortTextAnswerVM: PageVM {
    override func isCorrect(input: String, answer: String) -> Bool {
        return input == answer
    }
}
