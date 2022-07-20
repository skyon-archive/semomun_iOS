//
//  UserDefaultsManager.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/11.
//

import Foundation

@propertyWrapper
struct UserDefault<Value> {
    let key: String
    let defaultValue: Value
    private(set) var container: UserDefaults = .standard

    var wrappedValue: Value {
        get {
            return self.container.object(forKey: self.key) as? Value ?? self.defaultValue
        }
        set {
            print("UserDefault set '\(self.key)' to \(newValue)")
            self.container.set(newValue, forKey: self.key)
        }
    }
}

struct UserDefaultsManager {
    @UserDefault(key: "logined", defaultValue: false)
    static var isLogined: Bool
    
    @UserDefault(key: "isInitial", defaultValue: true)
    static var isInitial: Bool
    
    @UserDefault(key: "coreVersion", defaultValue: String.pastVersion)
    static var coreVersion: String
    
    @UserDefault(key: "favoriteTags", defaultValue: nil)
    static var favoriteTags: Data?
    
    @UserDefault(key: "workbookGroupsOrder", defaultValue: nil)
    static var workbookGroupsOrder: String?
    
    @UserDefault(key: "bookshelfOrder", defaultValue: nil)
    static var bookshelfOrder: String?
    
    @UserDefault(key: "lastViewedPopup", defaultValue: nil)
    static var lastViewedPopup: String?
}
