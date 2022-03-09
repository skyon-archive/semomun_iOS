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
            guard result.userAlreadyExist == false else {
                self?.status = .userAlreadyExist
                return
            }
            switch result.status {
            case .SUCCESS:
                // 회원가입시: UserVersion, CoreVersion 반영
                let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? String.currentVersion
                UserDefaultsManager.set(to: version, forKey: .coreVersion)
                
                SyncUsecase.syncUserDataFromDB { result in
                    switch result {
                    case .success(_):
                        self?.finalizeProcess(userID: userIDToken.userID)
                    case .failure(let error):
                        print("회원가입 중 회원 정보와 DB 동기화 실패: \(error)")
                    }
                }
            default:
                self?.alert = LoginSelectVMAlert.networkError
            }
        }
    }
    
    func login(userIDToken: NetworkURL.UserIDToken) {
        self.networkUsecase.postLogin(userToken: userIDToken) { [weak self] result in
            guard result.userNotExist == false else {
                self?.status = .userNotExist
                return
            }
            
            switch result.status {
            case .SUCCESS:
                SyncUsecase.syncUserDataFromDB { result in
                    self?.finalizeProcess(userID: userIDToken.userID)
                }
            default:
                self?.alert = LoginSelectVMAlert.networkError
            }
        }
    }
    
    private func finalizeProcess(userID: String) {
        UserDefaultsManager.set(to: true, forKey: .logined)
        do {
            try KeychainItem(account: .userIdentifier).saveItem(userID)
            self.status = .complete
        } catch {
            print("User ID 키체인 저장 실패: \(error)")
        }
    }
}
