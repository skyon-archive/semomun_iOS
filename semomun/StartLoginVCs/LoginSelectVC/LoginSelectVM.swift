//
//  LoginSelectVM.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/03/10.
//

import Foundation

typealias LoginSelectVMNetworkUsecase = (LoginSignupPostable & UserInfoSendable & UserInfoFetchable)

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
    
    /// 덮어쓰기를 위해 저장해놓는 값
    private var backupForPaste: NetworkURL.UserIDToken?
    private let networkUsecase: LoginSelectVMNetworkUsecase
    
    init(networkUsecase: LoginSelectVMNetworkUsecase) {
        self.networkUsecase = networkUsecase
    }
    
    func signup(userIDToken: NetworkURL.UserIDToken, userInfo: SignupUserInfo) {
        self.backupForPaste = userIDToken
        self.networkUsecase.postSignup(userIDToken: userIDToken, userInfo: userInfo) { [weak self] result in
            self?.handleSignupNetworkResult(token: userIDToken.userID, networkResult: result)
        }
    }
    
    func login(userIDToken: NetworkURL.UserIDToken) {
        self.networkUsecase.postLogin(userToken: userIDToken) { [weak self] result in
            self?.handleLoginNetworkResult(token: userIDToken.userID, networkResult: result)
        }
    }
    
    func pasteUserInfo(signupUserInfo: SignupUserInfo) {
        guard let backupForPaste = backupForPaste else {
            assertionFailure()
            return
        }
        self.networkUsecase.postLogin(userToken: backupForPaste) { [weak self] result in
            self?.handlePasteNetworkResult(signupUserInfo: signupUserInfo, token: backupForPaste.userID, status: result.status)
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

// MARK: 기존 정보 붙여넣기
extension LoginSelectVM {
    private func handlePasteNetworkResult(signupUserInfo: SignupUserInfo, token: String, status: NetworkStatus) {
        switch status {
        case .SUCCESS:
            self.postUpdatedUserInfo(signupUserInfo: signupUserInfo) { isSuccess in
                if isSuccess {
                    self.setLocalDataAfterLoginSuccess(token: token)
                } else {
                    self.alert = LoginSelectVMAlert.networkError
                }
            }
        default:
            self.alert = LoginSelectVMAlert.networkError
        }
    }
    
    private func postUpdatedUserInfo(signupUserInfo: SignupUserInfo, completion: @escaping (Bool) -> Void) {
        self.networkUsecase.getUserInfo { [weak self] status, userInfo in
            guard let strongSelf = self else {
                completion(false)
                return
            }
            guard let userInfo = userInfo else {
                strongSelf.alert = LoginSelectVMAlert.networkError
                completion(false)
                return
            }
            if case .SUCCESS = status {
                let updatedUserInfo = strongSelf.makePastedUserInfo(signupUserInfo: signupUserInfo, userInfo: userInfo)
                strongSelf.networkUsecase.putUserInfoUpdate(userInfo: updatedUserInfo) { status in
                    if case .SUCCESS = status {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            } else {
                completion(false)
            }
        }
    }
    
    private func makePastedUserInfo(signupUserInfo: SignupUserInfo, userInfo: UserInfo) -> UserInfo {
        var updatedUserInfo = userInfo
        updatedUserInfo.graduationStatus = signupUserInfo.graduationStatus
        updatedUserInfo.major = signupUserInfo.major
        updatedUserInfo.majorDetail = signupUserInfo.majorDetail
        updatedUserInfo.phoneNumber = signupUserInfo.phone
        updatedUserInfo.school = signupUserInfo.school
        updatedUserInfo.username = signupUserInfo.username
        return updatedUserInfo
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
