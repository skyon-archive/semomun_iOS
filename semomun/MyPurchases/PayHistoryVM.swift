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
    
    var isPaging = false
    @Published private(set) var purchasedItems: [PurchasedItem] = []
    @Published private(set) var alert: Alert?
    let networkUsecase: (PayNetworkUsecase&S3ImageFetchable)
    
    private let onlyPurchaseHistory: Bool
    private var page = 1
    private var isLastPage = false
    
    init(onlyPurchaseHistory: Bool, networkUsecase: (PayNetworkUsecase&S3ImageFetchable)) {
        self.onlyPurchaseHistory = onlyPurchaseHistory
        self.networkUsecase = networkUsecase
    }
    
    func fetch() {
        guard self.isPaging == false, self.isLastPage == false else { return }
        self.isPaging = true
        self.networkUsecase.getPayHistory(onlyPurchaseHistory: self.onlyPurchaseHistory, page: page) { [weak self] status, result in
            
            guard status == .SUCCESS,
                  let result = result else {
                self?.alert = .noNetwork
                return
            }
            
            self?.isLastPage = result.content.isEmpty
            self?.purchasedItems.append(contentsOf: result.content)
            self?.page += 1
        }
    }
}
