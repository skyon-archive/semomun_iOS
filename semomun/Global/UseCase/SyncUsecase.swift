//
//  SyncUsecase.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/02/23.
//

import Foundation

typealias SyncFetchable = (UserInfoFetchable & LoginSignupPostable)

struct SyncUsecase {
    
    enum SyncError: Error {
        case networkFail
        case coreDataFetchFail
        case tagOfDBEncodeFail
    }
    
    private let networkUsecase: SyncFetchable
    
    init(networkUsecase: SyncFetchable) {
        self.networkUsecase = networkUsecase
    }
    
    // MARK: AppDelegate 에서 1.0 -> 2.0 업데이트 로직
    func getTokensForPastVersionUser(completion: @escaping (Bool) -> Void) {
        do {
            let tokenString = try KeychainItem(account: .userIdentifier).readItem()
            let userToken = NetworkURL.UserIDToken.legacy(tokenString)
            
            self.networkUsecase.postLogin(userToken: userToken) { status, userNotExist in
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
    
    func syncUserDataFromDB(completion: @escaping (Result<UserInfo, SyncError>) -> Void) {
        self.networkUsecase.getUserInfo { status, userInfo in
            switch status {
            case .SUCCESS where userInfo != nil:
                self.saveUserInfoToCoreData(userInfo!)
                completion(.success(userInfo!))
            case .TOKENEXPIRED:
                NotificationCenter.default.post(name: .tokenExpired, object: nil)
                return
            default:
                completion(.failure(.networkFail))
                return
            }
            
            self.networkUsecase.getUserSelectedTags { status, tags in
                guard status == .SUCCESS else {
                    completion(.failure(.networkFail))
                    return
                }
                
                do {
                    let data = try PropertyListEncoder().encode(tags)
                    UserDefaultsManager.favoriteTags = data
                    NotificationCenter.default.post(name: .refreshFavoriteTags, object: nil)
                } catch {
                    print("Sync 실패: \(error)")
                    completion(.failure(.tagOfDBEncodeFail))
                    return
                }
            }
        }
    }
    
    private func saveUserInfoToCoreData(_ userInfo: UserInfo) {
        if let userCoreData = CoreUsecase.fetchUserInfo() {
            userCoreData.setValues(userInfo: userInfo)
            CoreDataManager.saveCoreData()
        } else {
            CoreUsecase.createUserCoreData(userInfo: userInfo)
        }
    }
}
