//
//  SyncUsecase.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/02/23.
//

import Foundation

typealias SyncFetchable = (UserInfoFetchable)

struct SyncUsecase {
    
    static private let networkUsecase: SyncFetchable = NetworkUsecase(network: Network())
    
    static func syncUserDataFromDB(completion: @escaping (Bool) -> Void) {
        self.networkUsecase.getUserInfo { status, userInfo in
            switch status {
            case .SUCCESS:
                guard let userInfo = userInfo,
                      let userCoreData = CoreUsecase.fetchUserInfo() else {
                          completion(false)
                          return
                      }
                userCoreData.setValues(userInfo: userInfo)
                CoreDataManager.saveCoreData()
                completion(true)
            default:
                completion(false)
            }
        }
    }
}
