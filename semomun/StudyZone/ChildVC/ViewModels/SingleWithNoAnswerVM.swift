//
//  SingleWithNoAnswerViewModel.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/15.
//

import Foundation

final class SingleWithNoAnswerVM: PageVM {
    override init(delegate: PageDelegate, pageData: PageData, mode: StudyVC.Mode?) {
        super.init(delegate: delegate, pageData: pageData, mode: mode)
        self.problem?.setValue(true, forKey: "correct")
    }
}
