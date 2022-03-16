//
//  MockPayNetworkUsecase.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/03/15.
//

import Foundation

struct MockPayNetworkUsecase: PayNetworkUsecase {
    typealias PayHistoryConforming = MockPayHistoryGroup
    
    private let historyCount = 212
    
    func getPayHistory(onlyPurchaseHistory: Bool, page: Int, completion: @escaping (NetworkStatus, MockPayHistoryGroup?) -> Void) {
        guard let range = returnedIndex(page: page) else {
            completion(.SUCCESS, nil)
            return
        }
        let histories: [MockPayHistory] = (0..<self.historyCount).map {
            let name = "\($0)"
            let date = Date().addingTimeInterval(TimeInterval(-$0 * 86400))
            let transaction: Transaction
            if onlyPurchaseHistory {
                transaction = Transaction.purchase(123456)
            } else {
                transaction = [Transaction.purchase(123456), Transaction.charge(654321), Transaction.free].randomElement()!
            }
            return MockPayHistory(createdDate: date, transaction: transaction, title: name)
        }
        let historyGroup = MockPayHistoryGroup(count: self.historyCount, content: Array(histories[range]))
        completion(.SUCCESS, historyGroup)
    }
    
    private func returnedIndex(page: Int) -> Range<Int>? {
        let contentSizeRange = 0..<self.historyCount
        let defaultPageSize = 25
        
        let requestedContentLowerBound = (page - 1) * defaultPageSize
        let requestedContentUpperBound = requestedContentLowerBound + defaultPageSize
        let requestedContentRange = requestedContentLowerBound..<requestedContentUpperBound
        
        guard contentSizeRange.overlaps(requestedContentRange) else {
            return nil
        }
        
        let availableContentRange = contentSizeRange.clamped(to: requestedContentRange)
        
        print("Page: \(page)")
        print("PayHistory 범위: \(availableContentRange)")
        
        return availableContentRange
    }
    
    func getRemainingSemopay(completion: @escaping (NetworkStatus, Int?) -> Void) {
        completion(.SUCCESS, 123456789)
    }
    
    func getUserInfo(completion: @escaping (NetworkStatus, UserInfo?) -> Void) {
    }
    
}

struct MockPayHistoryGroup: PayHistory {
    typealias Item = MockPayHistory
    let count: Int
    let content: [MockPayHistory]
}

struct MockPayHistory: PurchasedItem {
    let createdDate: Date
    let transaction: Transaction
    let title: String
    let bookCoverImageID: UUID? = nil
}
