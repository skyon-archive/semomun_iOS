//
//  SyncUsecase.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/02/23.
//

import Foundation

typealias SyncFetchable = (UserInfoFetchable & LoginSignupPostable)

struct SyncUsecase {
    /// 1.0 -> 2.0 유저가 홈화면에 들어가기 전에 token refresh 완료되었는지 여부
    static private(set) var isPastUserGetTokenCompleted: Bool = false
    
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
                    Self.isPastUserGetTokenCompleted = true
                    completion(true)
                default:
                    completion(false)
                }
            }
        } catch {
            print("Auth/Refresh 토큰 발급 실패: \(error)")
        }
    }
    
    /// DB의 사용자 정보를 CoreData에 저장합니다. 토큰이 만료된 경우 tokenExpired Notification을 post합니다.
    func syncUserDataFromDB(completion: @escaping (Result<UserInfo, SyncError>) -> Void) {
        self.networkUsecase.getUserInfo { status, userInfo in
            switch status {
            case .SUCCESS:
                guard let userInfo = userInfo else {
                    completion(.failure(.networkFail))
                    return
                }

                self.saveUserInfoToCoreData(userInfo)
                self.syncTagOfDB { result in
                    switch result {
                    case .success(_):
                        completion(.success(userInfo))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .TOKENEXPIRED:
                NotificationCenter.default.post(name: .tokenExpired, object: nil)
            default:
                completion(.failure(.networkFail))
            }
        }
    }
    
    /// 로그인 이후 DB의 사용자 정보를 CoreData에 저장합니다. 토큰이 만료된 경우 tokenExpired Notification을 post하며, **이전에 로그인한 계정과 다른 계정으로 로그인한 경우에 CoreData를 제거합니다.**
    func syncUserDataAfterLogin(completion: @escaping (Result<UserInfo, SyncError>) -> Void) {
        self.networkUsecase.getUserInfo { status, userInfo in
            switch status {
            case .SUCCESS:
                guard let userInfo = userInfo else {
                    completion(.failure(.networkFail))
                    return
                }
                self.deleteAllCoreDataIfNewUIDSync(uid: userInfo.uid)
                self.saveUserInfoToCoreData(userInfo)
                self.syncTagOfDB { result in
                    switch result {
                    case .success(_):
                        completion(.success(userInfo))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .TOKENEXPIRED:
                NotificationCenter.default.post(name: .tokenExpired, object: nil)
            default:
                completion(.failure(.networkFail))
            }
        }
    }
    
    private func syncTagOfDB(completion: @escaping (Result<Bool, SyncError>) -> Void) {
        self.networkUsecase.getUserSelectedTags { status, tags in
            guard status == .SUCCESS else {
                completion(.failure(.networkFail))
                return
            }
            
            do {
                let data = try PropertyListEncoder().encode(tags)
                UserDefaultsManager.favoriteTags = data
                NotificationCenter.default.post(name: .refreshFavoriteTags, object: nil)
                completion(.success(true))
            } catch {
                print("Sync 실패: \(error)")
                completion(.failure(.tagOfDBEncodeFail))
            }
        }
    }
    
    private func deleteAllCoreDataIfNewUIDSync(uid: Int) {
        let uidKeychain = KeychainItem(account: .semomunUID)
        if let previousUID = try? uidKeychain.readItem() {
            if previousUID != String(uid) {
                CoreUsecase.deleteAllCoreData()
            }
            try? uidKeychain.deleteItem()
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
