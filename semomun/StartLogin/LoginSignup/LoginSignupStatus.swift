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
    
    static var snsLimitExceedAlert: Self {
        return .alertWithoutPop(title: "인증 횟수 초과", description: "1시간 후 다시 시도해주세요.")
    }
}

enum LoginSignupStatus {
    /// DB에서 중복되지 않는 유저 이름
    case usernameAvailable
    /// 이미 다른 사람에 의해 사용된 유저 이름
    case usernameAlreadyUsed
    /// 형식에 맞지 않는 유저 이름
    case usernameInvalid
    /// 형식에 맞는 유저 이름
    case usernameValid
    
    case phoneNumberInvalid
    case phoneNumberValid
    
    case wrongAuthCode
    case authComplete
    case authCodeSent
    
    /// 회원가입에 필요한 모든 유저 정보 입력됨
    case userInfoComplete
    /// 회원가입에 필요한 모든 유저 정보가 아직 입력되지 않음
    case userInfoIncomplete
    
    /// 인증회수 초과
    case smsLimitExceed
}
