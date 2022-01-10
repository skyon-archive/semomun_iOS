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
    static let base: String = "https://saemomoon.com"
    static let workbooks: String = base + "/workbooks/"
    static let sections: String = base + "/sections/"
    static let images: String = base + "/images"
    static let workbookImageURL: String = images + "/workbook"
    static let bookcoverImageURL: String = images + "/bookcover"
    static let sectionImageURL: String = images + "/section"
    static let materialImage: String = images + "/material/"
    static let contentImage: String = images + "/content/"
    static let explanation: String = images + "/explanation/"
    static let checkUser: String = base + "/register/check"
    static let categorys: String = base + "/info/category"
    static let queryButtons: String = base + "/info/buttons"
    static let majors: String = base + "/info/major"
    static let register: String = base + "/register"
    static let postPhone: String = register + "/auth"
    static let verifyPhone: String = register + "/verify"
    static let users: String = base + "/users/"
    static let schoolApi: String = "https://www.career.go.kr/cnet/openapi/getOpenApi"
    static let customerService: String = "http://pf.kakao.com/_JAxdGb"
    static let errorReport: String = "https://forms.gle/suXByYKEied6RcSd8"
    static let appstoreVersion: String = "https://itunes.apple.com/lookup?id=1601145709"
    
    static var workbookImageDirectory: (scale) -> String = { workbookImageURL + $0.rawValue }
    static var bookcovoerImageDirectory: (scale) -> String = { bookcoverImageURL + $0.rawValue }
    static var sectionImageDirectory: (scale) -> String = { sectionImageURL + $0.rawValue }
    static var workbookDirectory: (Int) -> String = { workbooks + "\($0)" }
    static var sectionDirectory: (Int) -> String = { sections + "\($0)" }
    static var sectionsSubmit: (Int) -> String = { sections + "\($0)" + "/submission" }
}
