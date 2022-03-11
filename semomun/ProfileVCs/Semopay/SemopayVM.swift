//
//  SemopayVM.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/30.
//

import Foundation
import Combine

typealias SemopayNetworkUsecase = (UserHistoryFetchable & UserInfoFetchable & SemopayCellNetworkUsecase)

final class SemopayVM {
    @Published private(set) var purchaseOfEachMonth: [(section: String, content: [PayHistory])] = []
    @Published private(set) var remainingSemopay: Int = 0
    
    let networkUsecase: SemopayNetworkUsecase
    
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
                var resultGroupedByYearMonth: [String: [PayHistory]] = [:]
                result.forEach { purchase in
                    let yearMonthText = purchase.date.yearMonthText
                    resultGroupedByYearMonth[yearMonthText, default: []].append(purchase)
                }
                self?.purchaseOfEachMonth = resultGroupedByYearMonth.sorted(by: { $0.key > $1.key}).map { ($0.key, $0.value) }
            }
        }
    }
    private func initRemainingSemopay() {
        self.networkUsecase.getRemainingSemopay { [weak self] status, credit in
            if status == .SUCCESS {
                self?.remainingSemopay = credit ?? 0
            }
        }
    }
}
