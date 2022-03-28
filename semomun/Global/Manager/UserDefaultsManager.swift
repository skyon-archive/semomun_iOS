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
    var container: UserDefaults = .standard

    var wrappedValue: Value {
        get {
            return container.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            print("UserDefault set '\(key)' to \(newValue)")
            container.set(newValue, forKey: key)
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
    
    @UserDefault(key: "bookshelfOrder", defaultValue: nil)
    static var bookshelfOrder: String?
}
