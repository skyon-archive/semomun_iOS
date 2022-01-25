//
//  UserDefaultsManager.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/11.
//

import Foundation

struct UserDefaultsManager {
    enum Keys {
        static let currentCategory = "currentCategory"
        static let logined = "logined"
        static let isInitial = "isInitial"
        static let favoriteTags = "favoriteTags"
    }
    
    static func set<T>(to: T, forKey: String) {
        UserDefaults.standard.setValue(to, forKey: forKey)
        print("save \(forKey) complete")
    }
    
    static func get(forKey: String) -> Any? {
        return UserDefaults.standard.object(forKey: forKey)
    }
}
