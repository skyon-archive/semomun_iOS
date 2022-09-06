//
//  SubscriptionVertifier.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/09/06.
//

import Foundation
import SwiftyStoreKit

class SubscriptionVertifier {
    private init() {
        NotificationCenter.default.addObserver(forName: .updateSubscription, object: nil, queue: .current) { [weak self] _ in
            self?.lastVerified = nil
        }
        NotificationCenter.default.addObserver(forName: .logout, object: nil, queue: .current) { [weak self] _ in
            self?.lastVerified = nil
        }
    }
    static let shared = SubscriptionVertifier()
    private var lastVerified: Date?
    private var subscripted: Bool = false
    
    func checkSubscripted(completion: @escaping (Result<Bool, ReceiptError>) -> Void) {
        if let lastVerified = lastVerified {
            if -300 < lastVerified.timeIntervalSinceNow {
                completion(.success(subscripted))
                return
            }
        }
        
        guard let sharedSecret = Bundle.main.infoDictionary?["SUBSCRIPTION_SECRET"] as? String else {
            assertionFailure()
            return
        }
        
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { [weak self] result in
            self?.lastVerified = Date()
            switch result {
            case .success(let receipt):
                let productId = "com.skyon.semomun.monthlysubscription"
                // Verify the purchase of a Subscription
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable, // or .nonRenewing (see below)
                    productId: productId,
                    inReceipt: receipt
                )
                    
                switch purchaseResult {
                case .purchased(let expiryDate, let items):
                    print("\(productId) is valid until \(expiryDate)\n\(items)\n")
                    self?.subscripted = true
                    completion(.success(true))
                case .expired(let expiryDate, let items):
                    print("\(productId) is expired since \(expiryDate)\n\(items)\n")
                    self?.subscripted = false
                    completion(.success(false))
                case .notPurchased:
                    print("The user has never purchased \(productId)")
                    self?.subscripted = false
                    completion(.success(false))
                }
            case .error(let error):
                print("Receipt verification failed: \(error)")
                completion(.failure(error))
            }
        }
    }
}
