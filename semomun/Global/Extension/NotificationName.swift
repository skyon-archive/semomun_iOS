//
//  NotificationName.swift
//  semomun
//
//  Created by Kang Minsang on 2021/11/27.
//

import Foundation

extension Notification.Name {
    static let updateCategory = Self.init(rawValue: "updateCategory")
    static let logined = Self.init(rawValue: "logined")
    static let fetchTagsFromSearch = Self.init(rawValue: "fetchTagsFromSearch")
    static let goToUpdateUserinfo = Self.init(rawValue: "goToUpdateUserinfo")
    static let goToCharge = Self.init(rawValue: "goToCharge")
    static let purchaseComplete = Self.init(rawValue: "purchaseComplete")
    static let purchaseBook = Self.init(rawValue: "purchaseBook")
    static let logout = Self.init(rawValue: "logout") // 로그인, 로그아웃 로직 및 UI가 달라져야 하는 부분에서 수신
    static let refreshFavoriteTags = Self.init(rawValue: "refreshFavoriteTags")
    static let sectionTerminated = Self.init(rawValue: "sectionTerminated")
    static let showSectionResult = Self.init(rawValue: "showSectionResult")
    static let showPracticeTestResult = Self.init(rawValue: "showPracticeTestResult")
    static let tokenExpired = Self.init(rawValue: "tokenExpired")
    static let networkError = Self.init(rawValue: "networkError")
    static let refreshBookshelf = Self.init(rawValue: "refreshBookshelf")
    static let saveCoreData = Self.init(rawValue: "saveCoreData")
    static let previousPage = Self.init(rawValue: "previousPage")
    static let nextPage = Self.init(rawValue: "nextPage")
    static let showSectionDeleteButton = Self.init(rawValue: "showSectionDeleteButton")
    static let hideSectionDeleteButton = Self.init(rawValue: "hideSectionDeleteButton")
    static let showRecentWorkbooks = Self.init(rawValue: "showRecentWorkbooks")
    static let showLoginStartVC = Self.init(rawValue: "showLoginStartVC")
}
