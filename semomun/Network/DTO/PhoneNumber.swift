//
//  PhoneNumber.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/02/26.
//

import Foundation

struct PhoneNumber {
    init?(_ phoneNum: String) {
        guard phoneNum.matchRegularExpression("^\\d{11}$") else { return nil }
        self.elevenDigit = phoneNum
    }
    init?(withHyphen phoneNum: String) {
        guard phoneNum.matchRegularExpression("^\\d{3}-\\d{4}-\\d{4}$") else { return nil }
        self.elevenDigit = phoneNum.split(separator: "-").joined()
    }
    init?(withHypenAndContryCode phoneNum: String) {
        guard phoneNum.matchRegularExpression("^\\+82-\\d{2}-\\d{4}-\\d{4}$") else { return nil }
        self.elevenDigit = phoneNum.replacingOccurrences(of: "^\\+82-(\\d{2})-(\\d{4})-(\\d{4})$", with: "0$1$2$3", options: .regularExpression, range: nil)
    }
    
    /// 01012345678 형식의 전화번호 문자열
    let elevenDigit: String
    
    /// 010-1234-5678 형식의 전화번호 문자열
    var withHyphen: String {
        return self.elevenDigit.replacingOccurrences(
            of: "(\\d{3})(\\d{4})(\\d{4})", with: "$1-$2-$3", options: .regularExpression, range: nil)
    }
    
    /// +82-10-1234-5678 형식의 전화번호 문자열
    var withHyphenAndCountryCode: String {
        return self.elevenDigit.replacingOccurrences(
            of: "0(\\d{2})(\\d{4})(\\d{4})", with: "+82-$1-$2-$3", options: .regularExpression, range: nil)
    }
}
