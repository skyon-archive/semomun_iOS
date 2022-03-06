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
    let username: String
    let phone: String
    let school: String
    let major: String
    let majorDetail: String
    let favoriteTags: [Int]
    let graduationStatus: String
}
