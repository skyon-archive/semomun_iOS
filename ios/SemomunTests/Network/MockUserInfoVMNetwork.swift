//
//  MockUserInfoVMNetwork.swift
//  semomunTests
//
//  Created by SEONG YEOL YI on 2022/04/06.
//

import Foundation
@testable import semomun

/// - Note: VM 속 객체를 외부에서 조작하기 위해 class로 선언
class MockUserInfoVMNetwork: ChangeUserInfoNetworkUseCase {
    var reachability = true
    var tooManyCodeRequest = false
    var userExist = false
    
    let usedName = ["hello1", "world2"]
    let validAuthCode = "123456"
    let majors = [
        Major(name: "A", details: ["1","2","3"]),
        Major(name: "B", details: ["4","5","6"]),
        Major(name: "C", details: ["7","8","9"]),
    ]
    let remainingPay = 123456
    
    lazy private(set) var userInfo: UserInfo = {
        let string = """
{
    "uid": 9,
    "username": "user57665",
    "name": "",
    "email": "",
    "gender": "",
    "birth": null,
    "phone": "+82-10-3280-8642",
    "major": "이과 계열",
    "majorDetail": "자연",
    "school": "서울대학교",
    "graduationStatus": "재학",
    "credit": 0,
    "createdAt": "2022-03-25T15:59:23.000Z",
    "updatedAt": "2022-03-26T06:13:44.000Z"
}
"""
        let data = string.data(using: .utf8)!
        return try! JSONDecoderWithDate().decode(UserInfo.self, from: data)
    }()
    
    func getMajors(completion: @escaping ([Major]?) -> Void) {
        guard self.reachability == true else {
            completion(nil)
            return
        }
        
        completion(self.majors)
    }
    
    func usernameAvailable(_ nickname: String, completion: @escaping (NetworkStatus, Bool) -> Void) {
        guard reachability == true else {
            completion(.FAIL, false)
            return
        }
        
        completion(.SUCCESS, self.usedName.contains(nickname) == false)
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
    
    func postLogin(userToken: NetworkURL.UserIDToken, completion: @escaping ((status: NetworkStatus, userNotExist: Bool)) -> Void) {
        completion((self.reachability ? .SUCCESS : .FAIL, self.userExist))
    }
    
    func postSignup(userIDToken: NetworkURL.UserIDToken, userInfo: SignupUserInfo, completion: @escaping ((status: NetworkStatus, userAlreadyExist: Bool)) -> Void) {
        completion((self.reachability ? .SUCCESS : .FAIL, self.userExist))
    }
    
    func getUserInfo(completion: @escaping (NetworkStatus, UserInfo?) -> Void) {
        guard reachability == true else {
            completion(.FAIL, nil)
            return
        }
        
        completion(.SUCCESS, self.userInfo)
    }
    
    func getRemainingPay(completion: @escaping (NetworkStatus, Int?) -> Void) {
        if self.reachability {
            completion(.SUCCESS, self.remainingPay)
        } else {
            completion(.FAIL, nil)
        }
        
    }
}
