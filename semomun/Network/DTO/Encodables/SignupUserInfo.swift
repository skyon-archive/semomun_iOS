//
//  SignUpUserInfo.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/03/03.
//

import Foundation

struct SignUpParam: Encodable {
    let info: SignupUserInfo
    let token: String
    let type: String
}

struct SignupUserInfo: Encodable {
    var username: String?
    var phone: String?
    var school: String?
    var major: String?
    var majorDetail: String?
    var favoriteTags: [Int] = []
    var graduationStatus: String? = "재학"
    var marketing: Bool = false
    
    var isValid: Bool {
        return [username, school, major, majorDetail, graduationStatus].allSatisfy { $0 != nil }
        && phone?.isValidPhoneNumberWithCountryCode == true
    }
}
