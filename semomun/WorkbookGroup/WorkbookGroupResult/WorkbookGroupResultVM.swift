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
    
    var formattedTotalTime: String {
        let second = self.sortedTestResults.reduce(0, { $0 + $1.totalTime })
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        return formatter.string(from: TimeInterval(second)) ?? "00:00:00"
    }
    
    var averageRank: Double {
        let rankSum = self.sortedTestResults.reduce(0.0, { $0 + Double($1.rank) })
        let averageRank = rankSum / Double(self.sortedTestResults.count)
        return (averageRank*10).rounded(.toNearestOrAwayFromZero)/10
    }
    
    /// 1/9(9등급)과 1(1등급) 사이의 값을 가지는 평균 등급의 정규화 값
    var normalizedAverageRank: Float {
        return (10-Float(self.averageRank))/9
    }
    
    /* private */
    private let wgid: Int
    private let networkUsecase: UserTestResultFetchable
    
    init(wgid: Int, networkUsecase: UserTestResultFetchable) {
        self.wgid = wgid
        self.networkUsecase = networkUsecase
    }
}

// MARK: Public
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
