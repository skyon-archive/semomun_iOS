//
//  SyncUsecase.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/02/23.
//

import Foundation

typealias SyncFetchable = (UserInfoFetchable)

struct SyncUsecase {
    
    enum SyncError: Error {
        case networkFail, coreDataFetchFail
    }
    
    static private let networkUsecase: SyncFetchable = NetworkUsecase(network: Network())
    
    // MARK: AppDelegate 에서 1.0 -> 2.0 업데이트 로직
    static func getTokensForPastVersionUser(networkUsecase: LoginSignupPostable, completion: @escaping (Bool) -> Void) {
        do {
            let tokenString = try KeychainItem(account: .userIdentifier).readItem()
            let userToken = NetworkURL.UserIDToken.apple(tokenString)
            
            // TODO: 타입 필요 없는 API로 대체하기
            networkUsecase.postLogin(userToken: userToken) { status, userNotExist in
                guard userNotExist == false else {
                    assertionFailure()
                    completion(false)
                    return
                }
                switch status {
                case .SUCCESS:
                    completion(true)
                default:
                    completion(false)
                }
            }
        } catch {
            print("Auth/Refresh 토큰 발급 실패: \(error)")
        }
    }
    
    static func syncUserDataFromDB(completion: @escaping (Result<UserInfo, SyncError>) -> Void) {
        self.networkUsecase.getUserInfo { status, userInfo in
            switch status {
            case .SUCCESS where userInfo != nil:
                self.saveUserInfoToCoreData(userInfo!)
                completion(.success(userInfo!))
            case .TOKENEXPIRED:
                self.handleTokenExpire()
            default:
                completion(.failure(.networkFail))
            }
        }
    }
    
    static private func saveUserInfoToCoreData(_ userInfo: UserInfo) {
        if let userCoreData = CoreUsecase.fetchUserInfo() {
            userCoreData.setValues(userInfo: userInfo)
            CoreDataManager.saveCoreData()
        } else {
            CoreUsecase.createUserCoreData(userInfo: userInfo)
        }
    }
    
    static private func handleTokenExpire() {
        LogoutUsecase.logout()
        NotificationCenter.default.post(name: .logout, object: nil)
    }
}
