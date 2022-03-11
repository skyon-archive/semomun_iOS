//
//  AccountUsecase.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/03/11.
//

import Foundation

struct AccountUsecase {
    static func setLocalDataAfterLogin(token: String, completion: @escaping (Bool) -> Void) {
        Self.syncUserDataAndSaveKeychain(token: token) { succeed in
            if succeed {
                Self.setUserDefaultsToLogined()
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    static func setLocalDataAfterSignup(token: String, completion: @escaping (Bool) -> Void) {
        Self.syncUserDataAndSaveKeychain(token: token) { succeed in
            if succeed {
                Self.updateCoreVersion()
                Self.setUserDefaultsToLogined()
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    static private func syncUserDataAndSaveKeychain(token: String, completion: @escaping (Bool) -> Void) {
        Self.tryDataSyncFromDB(token: token) { syncSucceed in
            if syncSucceed {
                self.saveUserIDToKeychain(token: token) { keyChainSaveSucceed in
                    completion(keyChainSaveSucceed)
                }
            } else {
                completion(false)
            }
        }
    }
    
    static private func tryDataSyncFromDB(token: String, completion: @escaping (Bool) -> Void) {
        SyncUsecase.syncUserDataFromDB { result in
            switch result {
            case .success(_):
                completion(true)
            case .failure(let error):
                print("회원가입 중 회원 정보와 DB 동기화 실패: \(error)")
                completion(false)
            }
        }
    }
    
    static private func saveUserIDToKeychain(token: String, completion: (Bool) -> Void) {
        do {
            try KeychainItem(account: .userIdentifier).saveItem(token)
            completion(true)
        } catch {
            print("User ID 키체인 저장 실패: \(error)")
            completion(false)
        }
    }
    
    static private func setUserDefaultsToLogined() {
        UserDefaultsManager.set(to: true, forKey: .logined)
    }
    
    static private func updateCoreVersion() {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? String.currentVersion
        UserDefaultsManager.set(to: version, forKey: .coreVersion)
    }
}
