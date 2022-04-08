//
//  UserNotice.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/02/03.
//

import Foundation

struct UserNotice: Codable {
    let title, text: String
    let createdDate: Date
    
    enum CodingKeys: String, CodingKey {
        case title, text
        case createdDate = "createdAt"
    }
}
