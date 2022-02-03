//
//  UserNotice.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/02/03.
//

import Foundation

struct UserNotice: Decodable {
    let title: String
    let date: Date
    let content: String
}
