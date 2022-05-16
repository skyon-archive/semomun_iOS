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
    
    func versionCompare(_ otherVersion: String) -> ComparisonResult {
        let versionDelimiter = "."

        var versionComponents = self.components(separatedBy: versionDelimiter)
        var otherVersionComponents = otherVersion.components(separatedBy: versionDelimiter)

        let zeroDiff = versionComponents.count - otherVersionComponents.count

        if zeroDiff == 0 {
            // 같은 형식
            return self.compare(otherVersion, options: .numeric)
        } else {
            // 0의 개수가 다름
            let zeros = Array(repeating: "0", count: abs(zeroDiff))
            if zeroDiff > 0 {
                otherVersionComponents.append(contentsOf: zeros) 
            } else {
                versionComponents.append(contentsOf: zeros)
            }
            return versionComponents.joined(separator: versionDelimiter)
                .compare(otherVersionComponents.joined(separator: versionDelimiter), options: .numeric) // <6>
        }
    }
    
    static let pastVersion: String = "1.1.3"
    
    static let currentVersion: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    
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
        return self.matchRegularExpression("^[0-9]*$")
    }
    
    /// 유저가 닉네임을 타이핑하는 동안 닉네임이 유효한지 체크
    /// - Note: 최소 길이 및 알파벳 개수 제한을 체크하지 않음
    var isValidUsernameDuringTyping: Bool {
        return self.matchRegularExpression("^[a-zA-Z0-9_]{0,20}$")
    }
    
    var isValidUsername: Bool {
        // TODO: 알파벳 개수 체크도 정규표현식으로 수정하기
        return self.matchRegularExpression("^[a-zA-Z0-9_]{5,20}$") && self.contains(where: { String($0).isAlphabet })
    }
    
    var isAlphabet: Bool {
        return self.matchRegularExpression("^[a-zA-Z]*$")
    }
}
