//
//  MyPurchasesVM.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/02/01.
//

import Foundation
import Combine

typealias MyPurchasesNetworkUsecase = UserHistoryFetchable & MyPurchaseCellNetworkUsecase

final class MyPurchasesVM {
    let networkUsecase: MyPurchasesNetworkUsecase
    
    enum MyPurchasesAlert {
        case networkFailonStart
    }
    
    enum PurchaseShowRange {
        case all
        case month(Int)
    }
    
    @Published private(set) var purchaseListToShow: [(section: String, contents: [Purchase])] = []
    @Published private(set) var alert: MyPurchasesAlert? = nil
    
    private var startDate = Date(timeIntervalSince1970: 0)
    private var endDate: Date {
        return Date()
    }
    
    init(networkUsecase: MyPurchasesNetworkUsecase) {
        self.networkUsecase = networkUsecase
    }
    
    func configurePublished() {
        self.fetchData()
    }
    
    func showLatestData(range: PurchaseShowRange) {
        switch range {
        case .all:
            self.startDate = Date(timeIntervalSince1970: 0)
        case .month(let monthRange):
            self.startDate = self.addMonth(to: startDate, n: monthRange) ?? self.startDate
        }
        self.fetchData()
    }
    
    private func fetchData() {
        self.networkUsecase.getPurchaseList(from: self.startDate, to: self.endDate) { [weak self] status, result in
            if status == .SUCCESS {
                let purchaseListDividedByMonth: [String: [Purchase]] = result.reduce(into: [:]) { result, next in
                    let sectionText = next.date.yearMonthText
                    result[sectionText, default: []].append(next)
                }
                self?.purchaseListToShow = purchaseListDividedByMonth.sorted(by: { $0.key > $1.key }).map { ($0.key, $0.value) }
            } else {
                self?.alert = .networkFailonStart
            }
        }
    }
    
    private func addMonth(to date: Date, n: Int) -> Date? {
        let calendar = Calendar.current
        return calendar.date(byAdding: .month, value: n, to: date)
    }
}
