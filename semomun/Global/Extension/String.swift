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
    
    static var randomPhoneNumber: String {
        let randomVal = Int.random(in: 0...99999999)
        return "010"+String(format: "%08d", randomVal)
    }
    
    var circledAnswer: String {
        switch self {
        case "1": return "⓵"
        case "2": return "⓶"
        case "3": return "⓷"
        case "4": return "⓸"
        case "5": return "⓹"
        default: return self
        }
    }
}
