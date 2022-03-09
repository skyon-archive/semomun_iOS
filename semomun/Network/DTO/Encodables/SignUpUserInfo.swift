//
//  SignUpUserInfo.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/03/03.
//

import Foundation

struct SignUpParam: Encodable {
    let info: SignUpUserInfo
    let token: String
    let type: String
}

struct SignUpUserInfo: Encodable {
    var username: String?
    var phone: String?
    var school: String?
    var major: String?
    var majorDetail: String?
    var favoriteTags: [Int] = []
    var graduationStatus: String?
}
