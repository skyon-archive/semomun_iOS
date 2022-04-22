//
//  ConceptViewModel.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/15.
//

import Foundation

final class ConceptVM: PageVM {
    override init(delegate: PageDelegate, pageData: PageData) {
        super.init(delegate: delegate, pageData: pageData)
        self.problem?.setValue(true, forKey: "correct")
    }
}
