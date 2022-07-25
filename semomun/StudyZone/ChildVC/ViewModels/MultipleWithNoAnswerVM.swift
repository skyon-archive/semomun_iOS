//
//  MultipleWithNoAnswerViewModel.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation

final class MultipleWithNoAnswerVM: PageVM {
    override init(delegate: PageDelegate, pageData: PageData, mode: StudyVC.Mode?) {
        super.init(delegate: delegate, pageData: pageData, mode: mode)
        // MARK: problems 모두 correct 하는 로직 수정 필요
        self.problem?.setValue(true, forKey: "correct")
    }
}