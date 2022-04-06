//
//  MockUserInfoVMNetwork.swift
//  semomunTests
//
//  Created by SEONG YEOL YI on 2022/04/06.
//

import Foundation
@testable import semomun

struct MockUserInfoVMNetwork: ChangeUserInfoNetworkUseCase {
    var reachability = true
    var tooManyCodeRequest = false
    let validName = "홍길동"
    let validAuthCode = "123456"
    
    func getMajors(completion: @escaping ([Major]?) -> Void) {
        guard self.reachability == true else {
            completion(nil)
            return
        }
        
        let majors = [
            Major(name: "A", details: ["1","2","3"]),
            Major(name: "B", details: ["4","5","6"]),
            Major(name: "C", details: ["7","8","9"]),
        ]
        
        completion(majors)
    }
    
    func checkRedundancy(ofNickname nickname: String, completion: @escaping (NetworkStatus, Bool) -> Void) {
        guard reachability == true else {
            completion(.FAIL, false)
            return
        }
        
        completion(.SUCCESS, nickname == self.validName)
    }
    
    func requestVerification(of phoneNumber: String, completion: @escaping (NetworkStatus) -> ()) {
        guard reachability == true else {
            completion(.FAIL)
            return
        }
        
        guard phoneNumber.isValidPhoneNumberWithCountryCode else {
            completion(.BADREQUEST)
            return
        }
        
        if self.tooManyCodeRequest {
            completion(.TOOMANYREQUESTS)
        } else {
            completion(.SUCCESS)
        }
    }
    
    func checkValidity(phoneNumber: String, code: String, completion: @escaping (NetworkStatus, Bool?) -> Void) {
        guard reachability == true else {
            completion(.FAIL, nil)
            return
        }
        
        completion(.SUCCESS, code == self.validAuthCode)
    }
    
    func putUserInfoUpdate(userInfo: UserInfo, completion: @escaping (NetworkStatus) -> Void) {
        completion(self.reachability ? .SUCCESS : .FAIL)
    }
    
    func postMarketingConsent(isConsent: Bool, completion: @escaping (NetworkStatus) -> Void) {
        completion(self.reachability ? .SUCCESS : .FAIL)
    }
}
