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
        case unspecified(String)
        var param: (type: String?, token: String) {
            switch self {
            case .google(let string):
                return ("google", string)
            case .apple(let string):
                return ("apple", string)
            case .unspecified(let string):
                return (nil, string)
            }
        }
        var userID: String {
            switch self {
            case .google(let string):
                return string
            case .apple(let string):
                return string
            case .unspecified(let string):
                return string
            }
        }
    }
    enum PurchasesOrder: String {
        case solve
        case purchase
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
    static let purchaseItem = base + "/pay/orders"
    static let enterWorkbook = workbooks + "solve"
    static let purchasedWorkbooks: String = workbooks + "purchased"
    static let username = base + "/users/username"
    static let payHistory = base + "/pay"
    
    static let schoolApi: String = "https://www.career.go.kr/cnet/openapi/getOpenApi"
    static let customerService: String = "http://pf.kakao.com/_JAxdGb"
    static let errorReport: String = "https://forms.gle/suXByYKEied6RcSd8"
    static let appstoreVersion: String = "https://itunes.apple.com/lookup?id=1601145709&country=kr"
    static let s3ImageDirectory: String = base + "/s3/presignedUrl"
    
    static var workbookDirectory: (Int) -> String = { workbooks + "\($0)" }
    static var sectionDirectory: (Int) -> String = { sections + "\($0)" }
    static var sectionsSubmit: (Int) -> String = { sections + "\($0)" + "/submission" }
}
