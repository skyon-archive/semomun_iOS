//
//  NetworkURL.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/10.
//

import Foundation

enum NetworkURL {
    enum scale: String {
        case small = "/64x64/"
        case normal = "/128x128/"
        case large = "/256x256/"
    }
    enum imageType: String {
        case bookcover
        case sectioncover
        case material
        case explanation
        case content
    }
    enum TagsOrder: String {
        case popularity
        case name
    }
    enum UserIDToken {
        case google(String)
        case apple(String)
        var paramValue: (type: String, token: String) {
            switch self {
            case .google(let string):
                return ("google", string)
            case .apple(let string):
                return ("apple", string)
            }
        }
    }
    
    static let appstore: String = "itms-apps://itunes.apple.com/app/id1601145709"
    static let base: String = "http://api.semomun.com:8080"
    static let workbooks: String = base + "/workbooks/"
    static let sections: String = base + "/sections/"
    static let images: String = base + "/images"
    static let majors: String = base + "/info/major"
    static let tags: String = base + "/tags"
    static let login: String = base + "/auth/login"
    static let signup: String = base + "/auth/signup"
    static let refreshToken: String = base + "/auth/refresh"
    static let usersSelf = base + "/users/self"
    static let requestSMS = base + "/sms/code"
    static let verifySMS = base + "/sms/code/verify"
    
    static let schoolApi: String = "https://www.career.go.kr/cnet/openapi/getOpenApi"
    static let customerService: String = "http://pf.kakao.com/_JAxdGb"
    static let errorReport: String = "https://forms.gle/suXByYKEied6RcSd8"
    static let appstoreVersion: String = "https://itunes.apple.com/lookup?id=1601145709&country=kr"
    static let s3ImageDirectory: String = base + "/s3/presignedUrl"
    
    static var workbookDirectory: (Int) -> String = { workbooks + "\($0)" }
    static var sectionDirectory: (Int) -> String = { sections + "\($0)" }
    static var sectionsSubmit: (Int) -> String = { sections + "\($0)" + "/submission" }
}
