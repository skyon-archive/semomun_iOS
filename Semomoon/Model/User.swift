//
//  User.swift
//  Semomoon
//
//  Created by Kang Minsang on 2021/09/05.
//

import Foundation

struct User: Codable {
    var uid: Int
    var auth: Int
    var username: String
    var email: String
    var password: String
    var settins: String
    var profile_image: Int
}
