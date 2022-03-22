//
//  String.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2021/12/22.
//

import Foundation

extension String {
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
    
    func matchRegularExpression(_ pattern: String) -> Bool {
        let range = NSRange(location: 0, length: self.utf16.count)
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
        return regex.firstMatch(in: self, options: [], range: range) != nil
    }
    
    static let pastVersion: String = "1.1.3"
    
    static let currentVersion: String = "2.0"
    
    static let latestCoreVersion: String = "2.0"
}

// MARK: 전화번호 검증 및 변환
extension String {
    /// 10-11자리 숫자로 구성된 문자열인지를 반환합니다.
    /// - 0212345678
    /// - 01012345678
    var isValidPhoneNumber: Bool {
        return self.matchRegularExpression("^\\d{10,11}$")
    }
    
    /// 대한민국 국가번호가 포함된 유효한 전화번호 문자열인지를 반환합니다.
    /// - +82-10-1234-5678
    /// - +82-2-1234-5678
    var isValidPhoneNumberWithCountryCode: Bool {
        return self.matchRegularExpression("^\\+\\d{1,4}-\\d{1,3}-\\d{3,4}-\\d{3,4}$")
    }
    
    var phoneNumberWithCountryCode: String? {
        guard self.isValidPhoneNumber else { return nil }
        return self.replacingOccurrences(of: "^0(\\d{1,2})(\\d{4})(\\d{4})$", with: "+82-$1-$2-$3", options: .regularExpression, range: nil)
    }
    
    var phoneNumberWithNumbers: String? {
        guard self.isValidPhoneNumberWithCountryCode else { return nil }
        return self.replacingOccurrences(of: "^\\+\\d{1,4}-(\\d{1,3})-(\\d{3,4})-(\\d{3,4})$", with: "0$1$2$3", options: .regularExpression, range: nil)
    }
}

// MARK: 닉네임/인증번호 검증
extension String {
    var isNumber: Bool {
        return self.matchRegularExpression("^[0-9]$")
    }
    
    var isValidUsernameCharacters: Bool {
        return self.matchRegularExpression("^[a-z0-9_]$")
    }
}
