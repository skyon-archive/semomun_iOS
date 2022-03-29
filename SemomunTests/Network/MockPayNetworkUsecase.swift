//
//  MockPayNetworkUsecase.swift
//  semomunTests
//
//  Created by SEONG YEOL YI on 2022/03/29.
//

@testable import semomun
import Foundation

/// 짝수번째 인덱스는 충전, 홀수번째는 구매인 PayHistory를 반환
struct MockPayNetworkUsecase: PayNetworkUsecase {
    let pageSize: Int
    let payHistoryCount: Int
    let remainingSemopay = 123456789
    
    let wholePayHistories: [PayHistoryofDB]
    let purchaseHistories: [PayHistoryofDB]
    
    init(payHistoryCount: Int, pageSize: Int = 25) {
        self.pageSize = pageSize
        self.payHistoryCount = payHistoryCount
        
        self.wholePayHistories = (0..<payHistoryCount).map { index in
            let purchaseWorkbookOfDB = PurchasedWorkbookofDB(title: "\(index)", bookcover: UUID())
            let purchasedItemOfDB = PurchasedItemofDB(workbook: purchaseWorkbookOfDB)
            
            let date = Date().addingTimeInterval(TimeInterval(-1 * 60 * 60 * 24 * index))
            let amount = index % 2 == 0 ? 10000 : -10000
            return PayHistoryofDB(item: purchasedItemOfDB, createdDate: date, amount: amount)
        }
        
        self.purchaseHistories = self.wholePayHistories.filter { $0.amount <= 0 }
    }
    
    func getPayHistory(onlyPurchaseHistory: Bool, page: Int, completion: @escaping (NetworkStatus, PayHistory?) -> Void) {
        let targetHistory = onlyPurchaseHistory ? self.purchaseHistories : self.wholePayHistories
        
        let requestedRange = (page-1)*pageSize..<page*pageSize
        let actualRange = 0..<targetHistory.count
        
        if requestedRange.overlaps(actualRange) == false {
            completion(.SUCCESS, nil)
        } else {
            let overlappedRange = requestedRange.clamped(to: actualRange)
            let data = Array(targetHistory[overlappedRange])
            
            let payHistoryGroupOfDB = PayHistoryGroupOfDB(count: payHistoryCount, content: data)
            let payHistory = PayHistory(networkDTO: payHistoryGroupOfDB)
            completion(.SUCCESS, payHistory)
        }
    }
    
    func getUserInfo(completion: @escaping (NetworkStatus, UserInfo?) -> Void) {
        completion(.FAIL, nil)
    }
    
    func getRemainingPay(completion: @escaping (NetworkStatus, Int?) -> Void) {
        completion(.SUCCESS, remainingSemopay)
    }
}
