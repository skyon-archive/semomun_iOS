//
//  WorkbookGroupResultVM.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/06/18.
//

import Foundation

final class WorkbookGroupResultVM {
    /* public */
    let sortedTestResults: [PrivateTestResultOfDB]
    let title: String
    
    init(workbookGroupInfo: WorkbookGroupInfo, testResults: [PrivateTestResultOfDB]) {
        self.title = workbookGroupInfo.title
        self.sortedTestResults = testResults.sorted(by: { $0.percentile > $1.percentile })
    }
}
