//
//  LogoutUsecase.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/03/06.
//

import Foundation
import Alamofire

/// - Note: CoreData는 로그인시 기존과 다른 UID를 가지는 경우에 삭제
struct LogoutUsecase {
    static func logout() {
        Self.saveUID()
        Self.deleteKeychain()
        Self.deleteUserDefaults()
        Session.clearSession()
        NotificationCenter.default.post(name: .logout, object: nil)
    }
    
    static private func saveUID() {
        guard let uid = CoreUsecase.fetchUserInfo()?.uid else { return }
        do {
            try KeychainItem(account: .semomunUID).saveItem(uid)
        } catch {
            print("UID save failed")
        }
    }
    
    static private func deleteKeychain() {
        // UID를 제외한 모든 키체인 삭제
        let items: [KeychainItem.Items] = [.accessToken, .refreshToken, .userIdentifier]
        do {
            try items
                .map { KeychainItem(account: $0) }
                .forEach { try $0.deleteItem() }
            print("keychain delete complete")
        } catch {
            assertionFailure("keychain delete failed")
        }
    }
    
    static private func deleteUserDefaults() {
        let dictionary = UserDefaults.standard.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            UserDefaults.standard.removeObject(forKey: key)
        }
        print("userDefaults delete complete")
    }
}
