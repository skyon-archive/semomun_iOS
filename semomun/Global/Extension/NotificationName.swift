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
}
