//
//  NetworkURL.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/10.
//

import Foundation

enum NetworkURL {
    // MARK: 테스트 서버일 경우 true 값으로 사용
    static let forTest: Bool = true
    // MARK: 출판사 제공용 테스트일 경우 testCompany 명 수정, 사내용일 경우 nil값 설정
    static let testCompany: String? = nil
    
    enum TestPublishCompany: String {
        case donga = "동아출판"
        case gaenyeomwonri = "개념원리"
    }
    
    enum scale: String {
        case small = "/64x64/"
        case normal = "/128x128/"
        case large = "/256x256/"
    }
    enum ImageType: String {
        case bookcover
        case sectioncover
        case material = "passage"
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
        case legacy(String)
        case review(String)
        
        var param: (type: String, token: String) {
            switch self {
            case .google(let string):
                return ("google", string)
            case .apple(let string):
                return ("apple", string)
            case .legacy(let string):
                return ("legacy", string)
            case .review(let string):
                return ("review", string)
            }
        }
        var userID: String {
            switch self {
            case .google(let string):
                return string
            case .apple(let string):
                return string
            case .legacy(let string):
                return string
            case .review(let string):
                return string
            }
        }
    }
    enum PurchasesOrder: String {
        case solve
        case purchase
    }
    
    static let appstore: String = "itms-apps://itunes.apple.com/app/id1601145709"
    static let base: String = Self.forTest ? "https://dev.api.semomun.com" : "https://api.semomun.com"
    static let tempBase: String = "https://d2qp2vqqyviv98.cloudfront.net/"
    static let workbooks: String = base + "/workbooks/"
    static let workbookGroups: String = base + "/workbookGroups"
    static let sections: String = base + "/sections/"
    static let images: String = base + "/images"
    static let majors: String = base + "/info/major"
    static let tags: String = base + "/tags"
    static let tagsSelf = tags + "/self"
    static let login: String = base + "/auth/login"
    static let signup: String = base + "/auth/signup"
    static let refreshToken: String = base + "/auth/refresh"
    static let usersSelf = base + "/users/self"
    static let requestSMS = base + "/sms/code"
    static let verifySMS = base + "/sms/code/verify"
    static let purchaseItem = base + "/pay/orders"
    static let enterWorkbook = workbooks + "solve"
    static let purchasedWorkbooks: String = workbooks + "purchased"
    static let bestsellers = workbooks + "/bestseller"
    static let username = base + "/users/username"
    static let payHistory = base + "/pay"
    static let submissionOfProblems = base + "/submissions"
    static let submissionOfPages = base + "/view-submissions"
    static let notices = base + "/notices"
    static let banners = base + "/banners"
    static let popup = base + "/popups"
    static let errorReportOfProblem = base + "/error-reports"
    
    static let schoolApi: String = "https://www.career.go.kr/cnet/openapi/getOpenApi"
    static let customerService: String = "http://pf.kakao.com/_JAxdGb"
    static let errorReportOfApp: String = "https://forms.gle/suXByYKEied6RcSd8"
    static let s3ImageDirectory: String = base + "/s3/presignedUrl"
    
    static let chargePay = "https://semomun.com/charge/tmp"
    static let removeAccount = "https://semomun.com" // MARK: - 2.0 은 사용중이지 않는 상태
    
    static var workbookDirectory: (Int) -> String = { workbooks + "\($0)" }
    static var sectionDirectory: (Int) -> String = { sections + "\($0)" }
}
