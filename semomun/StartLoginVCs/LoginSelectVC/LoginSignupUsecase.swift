//
//  LoginSignupUsecase.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/03/11.
//

import Foundation

protocol LoginSignupLogic {
    func setLocalDataAfterLogin(token: String, completion: @escaping (Bool) -> Void)
    func setLocalDataAfterSignup(token: String, completion: @escaping (Bool) -> Void)
}

struct LoginSignupUsecase: LoginSignupLogic  {
    private let syncUsecase: SyncUsecase
    
    init(networkUsecase: SyncFetchable) {
        self.syncUsecase = SyncUsecase(networkUsecase: networkUsecase)
    }
    
    // MARK: - LoginSelectVM 에서 로그인 이후 로직
    func setLocalDataAfterLogin(token: String, completion: @escaping (Bool) -> Void) {
        self.syncUserDataAndSaveKeychain(token: token) { succeed in
            if succeed {
                guard let userInfo = CoreUsecase.fetchUserInfo() else {
                    completion(false)
                    return
                }
                
                if userInfo.phoneNumber?.isValidPhoneNumber ?? false {
                    self.updateCoreVersion()
                }
                UserDefaultsManager.isLogined = true
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    // MARK: - LoginSelectVM 에서 회원가입 이후 로직
    func setLocalDataAfterSignup(token: String, completion: @escaping (Bool) -> Void) {
        self.syncUserDataAndSaveKeychain(token: token) { succeed in
            if succeed {
                self.updateCoreVersion()
                UserDefaultsManager.isLogined = true
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}
 
// MARK: Private
extension LoginSignupUsecase {
    private func syncUserDataAndSaveKeychain(token: String, completion: @escaping (Bool) -> Void) {
        self.syncUsecase.syncUserDataFromDB { result in
            switch result {
            case .success(_):
                let saveKeychainResult = self.saveUserIDToKeychain(token: token)
                completion(saveKeychainResult)
            case .failure(let error):
                print("회원가입 중 회원 정보와 DB 동기화 실패: \(error)")
                completion(false)
            }
        }
    }
    
    private func saveUserIDToKeychain(token: String) -> Bool {
        do {
            try KeychainItem(account: .userIdentifier).saveItem(token)
            return true
        } catch {
            print("User ID 키체인 저장 실패: \(error)")
            return false
        }
    }
    
    private func updateCoreVersion() {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? String.currentVersion
        UserDefaultsManager.coreVersion = version
    }
}
