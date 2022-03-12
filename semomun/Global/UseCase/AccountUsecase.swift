//
//  AccountUsecase.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/03/11.
//

import Foundation

struct AccountUsecase {
    // MARK: AppDelegate 에서 1.0 -> 2.0 업데이트 로직
    static func getTokensForPastVersionUser(networkUsecase: LoginSignupPostable) {
        do {
            let tokenString = try KeychainItem(account: .userIdentifier).readItem()
            let userToken = NetworkURL.UserIDToken.apple(tokenString)
            
            // TODO: 타입 필요 없는 API로 대체하기
            networkUsecase.postLogin(userToken: userToken) { result in
                guard result.userNotExist == false else {
                    assertionFailure()
                    return
                }
                
                switch result.status {
                case .SUCCESS:
                    Self.setLocalDataAfterLogin(token: tokenString) { result in
                        if result {
                            print("1.0 유저 토큰 발급 성공")
                        } else {
                            print("1.0 유저 토큰 발급 실패")
                        }
                    }
                default:
                    print("1.0 유저 로그인 실패: \(result.status)")
                }
            }
        } catch {
            print("Auth/Refresh 토큰 발급 실패: \(error)")
        }
    }
    
    // MARK: - LoginSelectVM 에서 로그인 이후 로직
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
    
    // MARK: - LoginSelectVM 에서 회원가입 이후 로직
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
}
 
// MARK: Private
extension AccountUsecase {
    static private func syncUserDataAndSaveKeychain(token: String, completion: @escaping (Bool) -> Void) {
        Self.tryDataSyncFromDB() { syncSucceed in
            if syncSucceed {
                self.saveUserIDToKeychain(token: token) { keyChainSaveSucceed in
                    completion(keyChainSaveSucceed)
                }
            } else {
                completion(false)
            }
        }
    }
    
    static private func tryDataSyncFromDB(completion: @escaping (Bool) -> Void) {
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
