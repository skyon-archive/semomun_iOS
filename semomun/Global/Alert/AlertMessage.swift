//
//  AlertMessage.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/05/30.
//

import Foundation

struct AlertContent {
    let title: String
    let message: String?
    
    init(title: String, message: String? = nil) {
        self.title = title
        self.message = message
    }
}

extension AlertContent {
    static let loginNeeded: AlertContent = .init(title: "로그인이 필요한 서비스입니다.")
}
