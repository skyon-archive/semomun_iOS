//
//  WorkbookGroupResultVM.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/06/18.
//

import Foundation

fileprivate enum UserTestResultFetchError: Error {
    case failed
}

class WorkbookGroupResultVM {
    /* public */
    @Published private(set) var sortedTestResults: [PrivateTestResultOfDB] = []
    @Published private(set) var networkFailed: Bool?
    
    /* private */
    private let wgid: Int
    private let networkUsecase: UserTestResultFetchable
    
    init(wgid: Int, networkUsecase: UserTestResultFetchable) {
        self.wgid = wgid
        self.networkUsecase = networkUsecase
    }
}

extension WorkbookGroupResultVM {
    func fetchResult() {
        self.networkUsecase.getPrivateTestResults(wgid: wgid) { _, testResults in
            guard let testResults = testResults else {
                self.networkFailed = true
                return
            }

            self.sortedTestResults = testResults.sorted(by: { $0.percentile > $1.percentile })
        }
    }
}
