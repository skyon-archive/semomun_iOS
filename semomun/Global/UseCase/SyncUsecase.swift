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
