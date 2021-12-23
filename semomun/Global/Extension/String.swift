//
//  String.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2021/12/22.
//

import Foundation

extension String {
    static var randomUserNumber: String {
        let randomVal = Int.random(in: 0...99999)
        return String(format: "%05d", randomVal)
    }
    
    var circledAnswer: String {
        switch self {
        case "1": return "①"
        case "2": return "②"
        case "3": return "③"
        case "4": return "④"
        case "5": return "⑤"
        default: return self
        }
    }
}
