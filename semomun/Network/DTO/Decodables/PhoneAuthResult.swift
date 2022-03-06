//
//  PhoneAuthResult.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/03/05.
//

import Foundation

struct PhoneAuthResult: Decodable {
    private let result: String
    var succeed: Bool {
        return result == "ok"
    }
}
