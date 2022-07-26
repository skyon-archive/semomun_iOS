//
//  SingleWithSubProblemsVM.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/05/26.
//

import Foundation
import Combine

final class SingleWithSubProblemsVM: PageVM {
    override init(delegate: PageDelegate, pageData: PageData, mode: StudyVC.Mode?) {
        super.init(delegate: delegate, pageData: pageData, mode: mode)
    }
    
    override func isCorrect(input: String, answer: String) -> Bool {
        return input == answer
    }
    
    private func updateSolved(userAnswer: String, correctCount: Int) {
        self.updateSolved(withSelectedAnswer: userAnswer)
        self.problem?.setValue(Int64(correctCount), forKey: Problem_Core.Attribute.correctPoints.rawValue)
    }
}
