//
//  SemopayVM.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/30.
//

import Foundation
import Combine

typealias SemopayNetworkUsecase = PurchaseListFetchable

class SemopayVM {
    @Published private(set) var purchaseList: [Purchase] = []
    
    
    
    private let networkUsecase: SemopayNetworkUsecase
    
    init() {
        self.networkUsecase = NetworkUsecase(network: Network())
        self.networkUsecase.getPurchaseList { status, result in
            if status == .SUCCESS {
                self.purchaseList = result
            }
        }
    }
}
