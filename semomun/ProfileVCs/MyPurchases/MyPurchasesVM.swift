//
//  MyPurchasesVM.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/02/01.
//

import Foundation
import Combine

typealias MyPurchasesNetworkUsecase = PurchaseListFetchable

final class MyPurchasesVM {
    let networkUsecase: MyPurchasesNetworkUsecase
    
    enum MyPurchasesAlert {
        case networkFail
    }
    
    @Published private(set) var purchaseListToShow: [Purchase] = []
    @Published private(set) var alert: MyPurchasesAlert? = nil
    
    init(networkUsecase: MyPurchasesNetworkUsecase) {
        self.networkUsecase = networkUsecase
    }
    
    func configurePublished() {
        self.networkUsecase.getPurchaseList(from: Date(), to: Date()) { status, result in
            if status == .SUCCESS {
                self.purchaseListToShow = result
            } else {
                self.alert = .networkFail
            }
        }
    }
}
