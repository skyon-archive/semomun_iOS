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
    
    /// 10-11자리 숫자로 구성된 문자열인지를 반환합니다.
    /// - 02-1234-5678
    /// - 010-1234-5678
    var isValidPhoneNumber: Bool {
        return self.matchRegularExpression("^\\d{10,11}$")
    }
    
    /// 대한민국 국가번호가 포함된 유효한 전화번호 문자열인지를 반환합니다.
    /// - +82-10-1234-5678
    /// - +82-2-1234-5678
    var isValidPhoneNumberWithCountryCode: Bool {
        return self.matchRegularExpression("^\\+82-\\d{1,2}-\\d{4}-\\d{4}$")
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
