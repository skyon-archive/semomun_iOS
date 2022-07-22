//
//  WorkbookGroupResultVM.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/06/18.
//

import Foundation

final class WorkbookGroupResultVM {
    /* public */
    let title: String
    let sortedTestResults: [PrivateTestResultOfDB]
    let averagePercentile: Double
    
    init(workbookGroupInfo: WorkbookGroupInfo, testResults: [PrivateTestResultOfDB]) {
        self.title = workbookGroupInfo.title
        self.sortedTestResults = testResults.sorted(by: { $0.percentile > $1.percentile })
        self.averagePercentile = (Double(self.sortedTestResults.map(\.percentile).reduce(0, +)) / Double(self.sortedTestResults.count))/100
    }
}
