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
    
    private var paginationStarted = false
    private var latestFetchedPage = 0
    private var purchaseTotalCount: Int?
    
    private var canFetchMore: Bool {
        guard let purchaseTotalCount = purchaseTotalCount else {
            return false
        }
        return self.purchaseOfEachMonth.map(\.content).flatMap({$0}).count < purchaseTotalCount
    }
    
    init(networkUsecase: SemopayNetworkUsecase) {
        self.networkUsecase = networkUsecase
        self.initSemopayHistory()
        self.initRemainingSemopay()
    }
    
    func tryFetchMoreList() {
        if self.canFetchMore {
            let nextPage = self.latestFetchedPage + 1
            self.tryFetchPayHistory(page: nextPage)
        }
    }
}

extension SemopayVM {
    private func initSemopayHistory() {
        self.tryFetchPayHistory(page: 1)
    }
    
    private func initRemainingSemopay() {
        self.networkUsecase.getRemainingSemopay { [weak self] status, credit in
            if status == .SUCCESS {
                self?.remainingSemopay = credit ?? 0
            }
        }
    }
    
    private func tryFetchPayHistory(page: Int) {
        guard self.paginationStarted == false else { return }
        self.paginationStarted = true
        
        self.networkUsecase.getSemopayHistory(page: page) { [weak self] status, result in
            guard let result = result else {
                self?.paginationStarted = false
                return
            }
            self?.latestFetchedPage = page
            self?.purchaseTotalCount = result.count
            self?.addPayHistoriesGroupedByDate(result.content)
            self?.paginationStarted = false
        }
    }
    
    private func addPayHistoriesGroupedByDate(_ payHistories: [PayHistory]) {
        var resultGroupedByYearMonth: [String: [PayHistory]] = [:]
        payHistories.forEach { purchase in
            let yearMonthText = purchase.createdDate.yearMonthText
            resultGroupedByYearMonth[yearMonthText, default: []].append(purchase)
        }
        let sortedTuples = resultGroupedByYearMonth.sorted(by: { $0.key > $1.key}).map { ($0.key, $0.value) }
        sortedTuples.forEach { section, content in
            if let idx = self.purchaseOfEachMonth.firstIndex(where: { $0.section == section}) {
                self.purchaseOfEachMonth[idx].content.append(contentsOf: content)
            } else {
                self.purchaseOfEachMonth.append((section, content))
            }
        }
    }
}
