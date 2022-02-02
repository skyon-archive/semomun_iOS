//
//  NotificationName.swift
//  semomun
//
//  Created by Kang Minsang on 2021/11/27.
//

import Foundation

extension Notification.Name {
    static let seconds = Self.init(rawValue: "seconds")
    static let updateCategory = Self.init(rawValue: "updateCategory")
    static let logined = Self.init(rawValue: "logined")
    static let downloadPreview = Self.init(rawValue: "downloadPreview")
    static let showSection = Self.init(rawValue: "showSection")
    static let downloadSectionFail = Self.init(rawValue: "downloadSectionFail")
    static let goToMain = Self.init(rawValue: "goToMain")
    static let fetchTagsFromSearch = Self.init(rawValue: "fetchTagsFromSearch")
    static let searchWorkbook = Self.init(rawValue: "searchWorkbook")
    static let goToLogin = Self.init(rawValue: "goToLogin")
    static let goToUpdateUserinfo = Self.init(rawValue: "goToUpdateUserinfo")
    static let goToCharge = Self.init(rawValue: "goToCharge")
    static let purchaseComplete = Self.init(rawValue: "purchaseComplete")
    static let refreshBookshelf = Self.init(rawValue: "refreshBookshelf")
}
