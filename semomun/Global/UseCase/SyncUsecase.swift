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
            case .SUCCESS:
                guard let userInfo = userInfo,
                      let userCoreData = CoreUsecase.fetchUserInfo() else {
                          completion(.failure(.coreDataFetchFail))
                          return
                      }
                userCoreData.setValues(userInfo: userInfo)
                CoreDataManager.saveCoreData()
                completion(.success(userInfo))
            case .TOKENEXPIRED:
                LogoutUsecase.logout()
                NotificationCenter.default.post(name: .logout, object: nil)
            default:
                completion(.failure(.networkFail))
            }
        }
    }
}
