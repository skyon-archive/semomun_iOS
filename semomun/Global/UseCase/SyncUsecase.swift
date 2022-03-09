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
        case networkFail, coreDataFetchFail, noCoreData
    }
    
    static private let networkUsecase: SyncFetchable = NetworkUsecase(network: Network())
    
    static func syncUserDataFromDB(completion: @escaping (Result<UserInfo, SyncError>) -> Void) {
        self.networkUsecase.getUserInfo { status, userInfo in
            switch status {
            case .SUCCESS:
                guard let userInfo = userInfo else {
                    completion(.failure(.networkFail))
                    return
                }
                if let userCoreData = CoreUsecase.fetchUserInfo() {
                    userCoreData.setValues(userInfo: userInfo)
                    CoreDataManager.saveCoreData()
                } else {
                    CoreUsecase.createUserCoreData(userInfo: userInfo)
                }
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
