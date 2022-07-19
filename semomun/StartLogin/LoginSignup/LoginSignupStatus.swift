//
//  LoginSignupStatus.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/03/09.
//

import Foundation

enum LoginSignupAlert {
    case alert(title: String, description: String?)
    
    static var networkError: Self {
        return .alert(title: "네트워크 에러", description: "네트워크가 연결되어있지 않습니다.")
    }
}

enum LoginSignupStatus {
    case phoneNumberInvalid // 형식에 맞지 않는 전화번호 입력값
    case smsLimitExceed // 인증 횟수 초과상태
    case phoneNumberValid // 형식에 맞는 전화번호 입력값
    
    case authCodeSent // 인증번호가 전송완료된 상태
    case wrongAuthCode // 인증번호가 틀린 경우
    case authComplete // 인증 완료
    
    case usernameInvalid // 형식에 맞지 않는 유저 이름
    case usernameAlreadyUsed // 이미 다른 사람에 의해 사용된 유저 이름
    case usernameAvailable // DB에서 중복되지 않는 유저 이름
    
    case userInfoComplete // 회원가입에 필요한 모든 유저 정보 입력됨
    case userInfoIncomplete // 회원가입에 필요한 모든 유저 정보가 아직 입력되지 않음
}
