//
//  SemopayVM.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/30.
//

import Foundation
import Combine

typealias SemopayNetworkUsecase = SemopayHistoryFetchable

class SemopayVM {
    @Published private(set) var purchaseOfEachMonth: [(section: String, content: [SemopayHistory])] = []
    
    private let networkUsecase: SemopayNetworkUsecase
    
    init() {
        self.networkUsecase = NetworkUsecase(network: Network())
        self.networkUsecase.getSemopayHistory { status, result in
            if status == .SUCCESS {
                var resultGroupedByYearMonth: [String: [SemopayHistory]] = [:]
                result.forEach { purchase in
                    let yearMonthText = self.makeYearMonthText(using: purchase.date)
                    resultGroupedByYearMonth[yearMonthText, default: []].append(purchase)
                }
                self.purchaseOfEachMonth = resultGroupedByYearMonth.sorted(by: { $0.key > $1.key}).map { ($0.key, $0.value) }
            }
        }
    }
}

extension SemopayVM {
    private func makeYearMonthText(using date: Date) -> String {
        let calendarDate = Calendar.current.dateComponents([.year, .month], from: date)
        guard let year = calendarDate.year, let month = calendarDate.month else { return "20xx.xx" }
        return String(format: "%d-%02d", year, month)
    }
}
