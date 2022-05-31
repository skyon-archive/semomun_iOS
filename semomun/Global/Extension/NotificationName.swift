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
    static let goToMain = Self.init(rawValue: "goToMain")
    static let fetchTagsFromSearch = Self.init(rawValue: "fetchTagsFromSearch")
    static let goToLogin = Self.init(rawValue: "goToLogin")
    static let goToUpdateUserinfo = Self.init(rawValue: "goToUpdateUserinfo")
    static let goToCharge = Self.init(rawValue: "goToCharge")
    static let purchaseComplete = Self.init(rawValue: "purchaseComplete")
    static let purchaseBook = Self.init(rawValue: "purchaseBook")
    static let logout = Self.init(rawValue: "logout")
    static let refreshFavoriteTags = Self.init(rawValue: "refreshFavoriteTags")
    static let sectionTerminated = Self.init(rawValue: "sectionTerminated")
    static let showSectionResult = Self.init(rawValue: "showSectionResult")
    static let checkHomeNetworkFetchable = Self.init(rawValue: "checkHomeNetworkFetchable")
    static let tokenExpired = Self.init(rawValue: "tokenExpired")
    static let networkError = Self.init(rawValue: "networkError")
    static let refreshBookshelf = Self.init(rawValue: "refreshBookshelf")
    static let goToBookShelf = Self.init(rawValue: "goToBookShelf")
    static let saveCoreData = Self.init(rawValue: "saveCoreData")
    static let beforePage = Self.init(rawValue: "beforePage")
    static let nextPage = Self.init(rawValue: "nextPage")
}
