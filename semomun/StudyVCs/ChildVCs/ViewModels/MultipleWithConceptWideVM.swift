//
//  MultipleWithConceptWideVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/05/24.
//

import Foundation

final class MultipleWithConceptWideVM: PageVM {
    override init(delegate: PageDelegate, pageData: PageData) {
        super.init(delegate: delegate, pageData: pageData)
        self.problem?.setValue(true, forKey: "correct")
    }
}
