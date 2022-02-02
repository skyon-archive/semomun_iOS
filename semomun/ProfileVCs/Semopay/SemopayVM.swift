//
//  SemopayVM.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/30.
//

import Foundation
import Combine

typealias SemopayNetworkUsecase = (SemopayHistoryFetchable & RemainingSemopayFetchable)

class SemopayVM {
    @Published private(set) var purchaseOfEachMonth: [(section: String, content: [SemopayHistory])] = []
    @Published private(set) var remainingSemopay: Int = 0
    
    private let networkUsecase: SemopayNetworkUsecase
    
    init(networkUsecase: SemopayNetworkUsecase) {
        self.networkUsecase = networkUsecase
        self.initSemopayHistory()
        self.initRemainingSemopay()
    }
}

extension SemopayVM {
    private func initSemopayHistory() {
        self.networkUsecase.getSemopayHistory { [weak self] status, result in
            if status == .SUCCESS {
                var resultGroupedByYearMonth: [String: [SemopayHistory]] = [:]
                result.forEach { purchase in
                    guard let yearMonthText = self?.makeYearMonthText(using: purchase.date) else { return }
                    resultGroupedByYearMonth[yearMonthText, default: []].append(purchase)
                }
                self?.purchaseOfEachMonth = resultGroupedByYearMonth.sorted(by: { $0.key > $1.key}).map { ($0.key, $0.value) }
            }
        }
    }
    private func initRemainingSemopay() {
        self.networkUsecase.getRemainingSemopay { [weak self] status, result in
            if status == .SUCCESS {
                self?.remainingSemopay = result
            }
        }
    }
    private func makeYearMonthText(using date: Date) -> String {
        let calendarDate = Calendar.current.dateComponents([.year, .month], from: date)
        guard let year = calendarDate.year, let month = calendarDate.month else { return "20xx.xx" }
        return String(format: "%d. %02d", year, month)
    }
}
