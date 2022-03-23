//
//  LoginSignupStatus.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/03/09.
//

import Foundation

enum LoginSignupAlert {
    case alertWithPop(title: String, description: String?)
    case alertWithoutPop(title: String, description: String?)
    
    static var networkErrorWithPop: Self {
        return .alertWithPop(title: "네트워크 에러", description: "네트워크가 연결되어있지 않습니다.")
    }
    
    static var networkErrorWithoutPop: Self {
        return .alertWithoutPop(title: "네트워크 에러", description: "네트워크가 연결되어있지 않습니다.")
    }
    
    static var codeSentAlert: Self {
        return .alertWithoutPop(title: "인증번호가 전송되었습니다", description: nil)
    }
    
    static var snsLimitExceedAlert: Self {
        return .alertWithoutPop(title: "인증 횟수 초과", description: "잠시 후 다시 시도해주세요.")
    }
    
    static var insufficientData: Self {
        return .alertWithoutPop(title: "비어있는 정보", description: "모든 정보를 입력하셨는지 확인해주세요.")
    }
}

enum LoginSignupStatus {
    case usernameNotInUse
    case usernameAlreadyUsed
    case usernameWrongFormat
    case usernameGoodFormat
    
    case phoneNumberWrongFormat
    case phoneNumberGoodFormat
    
    case wrongAuthCode
    case authComplete
    case authCodeSent
}
