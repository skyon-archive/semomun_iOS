//
//  MockPhoneNumVerifiable.swift
//  semomunTests
//
//  Created by SEONG YEOL YI on 2022/04/01.
//

@testable import semomun
import Foundation

final class MockPhoneNumVerifiable: PhonenumVerifiable {
    
    let testAuthCode = "123456"
    private(set) var inputParameter: String?
    var networkStatus: NetworkStatus = .SUCCESS
    
    func requestVerification(of phoneNumber: String, completion: @escaping (NetworkStatus) -> ()) {
        self.inputParameter = phoneNumber
        completion(self.networkStatus)
    }
    
    func checkValidity(phoneNumber: String, code: String, completion: @escaping (NetworkStatus, Bool?) -> Void) {
        self.inputParameter = "\(phoneNumber) \(code)"
        if self.networkStatus == .SUCCESS {
            completion(.SUCCESS, self.testAuthCode == code)
        } else {
            completion(self.networkStatus, nil)
        }
    }
}
