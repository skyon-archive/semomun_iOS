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
    
    static var nowTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale.current
        return formatter.string(from: Date())
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
    
    var isValidPhoneNumberWithCountryCode: Bool {
        return self.matchRegularExpression("^\\+82-\\d{2}-\\d{4}-\\d{4}$")
    }
    
    func matchRegularExpression(_ pattern: String) -> Bool {
        let range = NSRange(location: 0, length: self.utf16.count)
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
        return regex.firstMatch(in: self, options: [], range: range) != nil
    }
    
    static let pastVersion: String = "1.1.3"
    
    static let currentVersion: String = "2.0"
    
    static let latestCoreVersion: String = "2.0"
}
