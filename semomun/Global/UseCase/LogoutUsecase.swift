//
//  LogoutUsecase.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/03/06.
//

import Foundation

struct LogoutUsecase {
    static func logout() {
        CoreUsecase.deleteAllCoreData()
        Self.deleteKeychain()
        Self.deleteUserDefaults()
    }
    
    static private func deleteKeychain() {
        KeychainItem.deleteUserIdentifierFromKeychain()
        print("keychain delete complete")
    }
    
    static private func deleteUserDefaults() {
        let dictionary = UserDefaults.standard.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            UserDefaults.standard.removeObject(forKey: key)
        }
        print("userDefaults delete complete")
    }
}
