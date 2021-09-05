//
//  User.swift
//  User
//
//  Created by qwer on 2021/09/05.
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
