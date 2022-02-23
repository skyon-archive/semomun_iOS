//
//  UserDefaultsManager.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/11.
//

import Foundation

struct UserDefaultsManager {
    enum Keys: String {
        case currentCategory = "currentCategory"
        case logined = "logined"
        case isInitial = "isInitial"
        case favoriteTags = "favoriteTags"
        case coreVersion = "coreVersion"
    }
    
    static func set<T>(to: T, forKey: Self.Keys) {
        UserDefaults.standard.setValue(to, forKey: forKey.rawValue)
        print("UserDefaultManager: save \(forKey) complete")
    }
    
    static func get(forKey: Self.Keys) -> Any? {
        return UserDefaults.standard.object(forKey: forKey.rawValue)
    }
}
