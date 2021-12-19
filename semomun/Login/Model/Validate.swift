//
//  Validate.swift
//  Semomoon
//
//  Created by Kang Minsang on 2021/12/04.
//

import Foundation

struct Validate: Codable {
    let check: Bool
    
    enum CodingKeys: String, CodingKey {
        case check
    }
}
