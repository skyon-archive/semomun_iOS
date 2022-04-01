//
//  SemopayVM.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/30.
//

import Foundation
import Combine

typealias PayNetworkUsecase = (UserHistoryFetchable & UserInfoFetchable)

final class PayHistoryVM {
    enum Alert {
        case noNetwork
    }
    
    @Published private(set) var purchaseOfEachMonth: [(section: String, content: [PurchasedItem])] = []
    @Published private(set) var remainingSemopay: Int = 0
    @Published private(set) var alert: Alert?
    
    private let networkUsecase: PayNetworkUsecase
    private let onlyPurchaseHistory: Bool
    
    private var paginationStarted = false
    private var latestFetchedPage = 0
    private var purchaseTotalCount: Int?
    
    private var canFetchMore: Bool {
        guard let purchaseTotalCount = purchaseTotalCount else {
            return false
        }
        return self.purchaseOfEachMonth.reduce(0, { $0 + $1.content.count }) < purchaseTotalCount
    }
    
    init(onlyPurchaseHistory: Bool, networkUsecase: PayNetworkUsecase) {
        self.onlyPurchaseHistory = onlyPurchaseHistory
        self.networkUsecase = networkUsecase
    }
    
    func initPublished() {
        self.initRemainingSemopay()
        self.tryFetchPayHistory(page: 1)
    }
    
    func tryFetchMoreList() {
        if self.canFetchMore {
            let nextPage = self.latestFetchedPage + 1
            self.tryFetchPayHistory(page: nextPage)
        }
    }
}

extension PayHistoryVM {
    private func initRemainingSemopay() {
        self.networkUsecase.getRemainingPay { [weak self] status, credit in
            if status == .SUCCESS {
                self?.remainingSemopay = credit ?? 0
            } else {
                self?.alert = .noNetwork
            }
        }
    }
    
    private func tryFetchPayHistory(page: Int) {
        guard self.paginationStarted == false else { return }
        self.paginationStarted = true
        self.networkUsecase.getPayHistory(onlyPurchaseHistory: self.onlyPurchaseHistory, page: page) { [weak self] status, result in
            defer {
                self?.paginationStarted = false
            }
            
            guard status == .SUCCESS,
            let result = result else {
                self?.alert = .noNetwork
                return
            }
            
            self?.latestFetchedPage = page
            self?.purchaseTotalCount = result.count
            self?.addPayHistoriesGroupedByDate(result.content)
        }
    }
    
    private func addPayHistoriesGroupedByDate(_ payHistories: [PurchasedItem]) {
        let temp = Array(repeating: payHistories, count: 10).flatMap { $0 }
        let historyGrouped = Dictionary(grouping: temp, by: { $0.createdDate })
        let historySorted: [(String, [PurchasedItem])] = historyGrouped
            .sorted(by: { $0.key > $1.key }) // Date 키 값 기준으로 정렬
            .map { key, value in
                let dateStr = key.yearMonthText
                let contentSorted = value.sorted(by: { $0.createdDate > $1.createdDate })
                return (dateStr, contentSorted)
            }
        
        historySorted.forEach { section, content in
            if let idx = self.purchaseOfEachMonth.firstIndex(where: { $0.section == section}) {
                self.purchaseOfEachMonth[idx].content.append(contentsOf: content)
            } else {
                self.purchaseOfEachMonth.append((section, content))
            }
        }
    }
}
