//
//  LoginSelectVM.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/03/10.
//

import Foundation

class LoginSelectVM {
    enum LoginSelectVMAlert {
        static let decodeError = (title: "수신 불가", description: "최신버전으로 업데이트 후 다시 시도하시기 바랍니다.")
        static let networkError = (title: "네트워크 통신 에러", description: "인증에 실패하였습니다. 다시 시도하시기 바랍니다.")
    }
    
    enum LoginSelectVMStatus {
        case userAlreadyExist
        case userNotExist
        case complete
    }
    
    @Published var alert: (title: String, description: String?)?
    @Published var status: LoginSelectVMStatus?
    
    private let networkUsecase: LoginSignupPostable
    
    init(networkUsecase: LoginSignupPostable) {
        self.networkUsecase = networkUsecase
    }
    
    func signup(userIDToken: NetworkURL.UserIDToken, userInfo: SignupUserInfo) {
        self.networkUsecase.postSignup(userIDToken: userIDToken, userInfo: userInfo) { [weak self] result in
            self?.handleSignupNetworkResult(token: userIDToken.userID, networkResult: result)
        }
    }
    
    func login(userIDToken: NetworkURL.UserIDToken) {
        self.networkUsecase.postLogin(userToken: userIDToken) { [weak self] result in
            self?.handleLoginNetworkResult(token: userIDToken.userID, networkResult: result)
        }
    }
}

// MARK: 회원가입
extension LoginSelectVM {
    private func handleSignupNetworkResult(token: String, networkResult: (status: NetworkStatus, userAlreadyExist: Bool)) {
        if networkResult.userAlreadyExist {
            self.status = .userAlreadyExist
        } else {
            self.handleSignupNetworkStatus(token: token, status: networkResult.status)
        }
    }
    
    private func handleSignupNetworkStatus(token: String, status: NetworkStatus) {
        if case .SUCCESS = status {
            self.setLocalDataAfterSignupSuccess(token: token)
        } else {
            self.alert = LoginSelectVMAlert.networkError
        }
    }
    
    private func setLocalDataAfterSignupSuccess(token: String) {
        self.syncUserDataAndSaveKeychain(token: token) { [weak self] succeed in
            if succeed {
                self?.updateCoreVersion()
                self?.setUserDefaultsToLogined()
                self?.publishProcessFinished()
            } else {
                self?.alert = LoginSelectVMAlert.networkError
            }
        }
    }
}

// MARK: 로그인
extension LoginSelectVM {
    private func handleLoginNetworkResult(token: String, networkResult: (status: NetworkStatus, userNotExist: Bool)) {
        guard networkResult.userNotExist == false else {
            self.status = .userNotExist
            return
        }
        self.handleLoginNetworkStatus(token: token, status: networkResult.status)
    }
    
    private func handleLoginNetworkStatus(token: String, status: NetworkStatus) {
        switch status {
        case .SUCCESS:
            self.setLocalDataAfterLoginSuccess(token: token)
        default:
            self.alert = LoginSelectVMAlert.networkError
        }
    }
    
    private func setLocalDataAfterLoginSuccess(token: String) {
        self.syncUserDataAndSaveKeychain(token: token) { [weak self] succeed in
            if succeed {
                self?.setUserDefaultsToLogined()
                self?.publishProcessFinished()
            } else {
                self?.alert = LoginSelectVMAlert.networkError
            }
        }
    }
}

// MARK: 공통
extension LoginSelectVM {
    private func syncUserDataAndSaveKeychain(token: String, completion: @escaping (Bool) -> Void) {
        self.tryDataSyncFromDB(token: token) { [weak self] syncSucceed in
            if syncSucceed {
                self?.saveUserIDToKeychain(token: token) { keyChainSaveSucceed in
                    completion(keyChainSaveSucceed)
                }
            } else {
                completion(false)
            }
        }
    }
    
    private func tryDataSyncFromDB(token: String, completion: @escaping (Bool) -> Void) {
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
    
    private func saveUserIDToKeychain(token: String, completion: (Bool) -> Void) {
        do {
            try KeychainItem(account: .userIdentifier).saveItem(token)
            completion(true)
        } catch {
            print("User ID 키체인 저장 실패: \(error)")
            completion(false)
        }
    }
    
    private func setUserDefaultsToLogined() {
        UserDefaultsManager.set(to: true, forKey: .logined)
    }
    
    private func updateCoreVersion() {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? String.currentVersion
        UserDefaultsManager.set(to: version, forKey: .coreVersion)
    }
    
    private func publishProcessFinished() {
        self.status = .complete
    }
}
