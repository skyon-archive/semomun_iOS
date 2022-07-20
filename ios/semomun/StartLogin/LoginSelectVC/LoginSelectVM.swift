//
//  LoginSelectVM.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/03/10.
//

import Foundation

typealias LoginSelectVMNetworkUsecase = (UserInfoSendable & UserInfoFetchable & SyncFetchable)

final class LoginSelectVM {
    enum LoginSelectVMAlert {
        static let decodeError = (title: "수신 불가", description: "최신버전으로 업데이트 후 다시 시도하시기 바랍니다.")
        static let networkError = (title: "네트워크 통신 에러", description: "인증에 실패하였습니다. 다시 시도하시기 바랍니다.")
    }
    
    enum LoginSelectVMStatus {
        case userNotExist
        case complete
    }
    
    @Published var alert: (title: String, description: String?)?
    @Published var status: LoginSelectVMStatus?
    
    var tags: [TagOfDB] {
        if let tagsData = UserDefaultsManager.favoriteTags,
           let tags = try? PropertyListDecoder().decode([TagOfDB].self, from: tagsData) {
            return tags
        } else {
            return []
        }
    }
    
    /// 덮어쓰기를 위해 저장해놓는 값
    private var backupForPaste: NetworkURL.UserIDToken?
    private let networkUsecase: LoginSelectVMNetworkUsecase
    private let usecase: LoginSignupLogic
    
    init(networkUsecase: LoginSelectVMNetworkUsecase, usecase: LoginSignupLogic) {
        self.networkUsecase = networkUsecase
        self.usecase = usecase
    }
    
    func login(userIDToken: NetworkURL.UserIDToken) {
        self.networkUsecase.postLogin(userToken: userIDToken) { [weak self] result in
            self?.handleLoginNetworkResult(token: userIDToken.userID, networkResult: result)
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
            self.networkUsecase.putUserSelectedTags(tags: tags) { [weak self] status in
                guard status == .SUCCESS else {
                    self?.alert = LoginSelectVMAlert.networkError
                    return
                }
                guard let networkUsecase = self?.networkUsecase else { return }
                LoginSignupUsecase(networkUsecase: networkUsecase).setLocalDataAfterLogin(token: token) { isSuccess in
                    self?.handleLocalDataSettingResult(isSuccess: isSuccess)
                }
            }
        default:
            self.alert = LoginSelectVMAlert.networkError
        }
    }
}

// MARK: 공통
extension LoginSelectVM {
    private func handleLocalDataSettingResult(isSuccess: Bool) {
        if isSuccess {
            self.status = .complete
        } else {
            self.alert = LoginSelectVMAlert.networkError
        }
    }
}
