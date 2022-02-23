//
//  ChangeUserInfoVM.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/29.
//

import Foundation
import Combine

typealias ChangeUserInfoNetworkUseCase = (MajorFetchable & UserInfoSendable & NicknameCheckable & PhonenumVerifiable)

final class ChangeUserInfoVM {
    
    enum ChangeUserInfoAlert {
        case withPopVC(AlertMessage)
        case withoutPopVC(AlertMessage)
        enum AlertMessage: String {
            case incomplateData = "정보가 모두 입력되지 않았습니다"
            case networkError = "네트워크가 연결되어있지 않습니다"
            case coreDataFetchError = "일시적인 문제가 발생했습니다"
            case saveSuccess = "저장이 완료되었습니다"
            case majorDetailNotSelected = "전공을 선택해주세요"
        }
    }
    
    enum PhoneAuthStatus {
        case authNumSent, authComplete, wrongAuthNumber, invaildPhoneNum
    }
    
    @Published private(set) var alertStatus: ChangeUserInfoAlert? = nil
    @Published private(set) var phoneAuthStatus: PhoneAuthStatus?
    
    @Published private(set) var nickname: String?
    @Published private(set) var phonenum: String?
    @Published private(set) var majors: [String]?
    @Published private(set) var majorDetails: [String]?
    @Published var schoolName: String?
    @Published var graduationStatus: String?
    
    private(set) var selectedMajor: String?
    private(set) var selectedMajorDetail: String?
    
    private let networkUseCase: ChangeUserInfoNetworkUseCase
    private let isSignup: Bool
    private var majorWithDetail: [String: [String]] = [:]
    private var waitingForAuthPhoneNum: String?
    
    init(networkUseCase: ChangeUserInfoNetworkUseCase, isSignup: Bool) {
        self.networkUseCase = networkUseCase
        self.isSignup = isSignup
        if isSignup == false {
            self.getUserInfo()
        }
        self.fetchMajorInfo()
    }
    
    func makeUserInfo() -> UserInfo {
        let userInfo = UserInfo()
        userInfo.nickName = self.nickname
        userInfo.phone = self.phonenum
        userInfo.major = self.selectedMajor
        userInfo.majorDetail = self.selectedMajorDetail
        userInfo.school = self.schoolName
        userInfo.graduationStatus = self.graduationStatus
        return userInfo
    }
    
    func changeNicknameIfAvailable(nickname: String, completion: @escaping (Bool) -> ()) {
        self.networkUseCase.checkRedundancy(ofNickname: nickname) { [weak self] status, isAvailable in
            if status == .SUCCESS {
                if isAvailable {
                    self?.nickname = nickname
                    completion(true)
                } else {
                    completion(false)
                }
            } else {
                self?.alertStatus = .withoutPopVC(.networkError)
                completion(false)
            }
        }
    }
    
    func selectMajor(at index: Int) {
        guard self.majors?.indices.contains(index) == true else { return }
        guard let majorName = majors?[index] else { return }
        self.selectedMajor = majorName
        self.majorDetails = majorWithDetail[majorName] ?? []
        self.selectedMajorDetail = nil
    }
    
    func selectMajorDetail(at index: Int) {
        guard self.majorDetails?.indices.contains(index) == true else { return }
        guard let majorDetailName = majorDetails?[index] else { return }
        self.selectedMajorDetail = majorDetailName
    }
    
    func submitUserInfo() {
        guard let userInfo = CoreUsecase.fetchUserInfo() else {
            self.alertStatus = .withoutPopVC(.coreDataFetchError)
            return
        }
        self.sendUserInfoToNetwork(userInfo: userInfo) { [weak self] isSuccess in
            if isSuccess {
                self?.saveUserInfoToCoreData(userInfo: userInfo)
                self?.updateVersionIfDataUpdateSucceed()
                self?.alertStatus = .withPopVC(.saveSuccess)
            } else {
                self?.alertStatus = .withoutPopVC(.networkError)
            }
        }
    }
    
    func requestPhoneAuth(withPhoneNumber phoneNum: String) {
        guard phoneNum.count == 11 else {
            self.phoneAuthStatus = .invaildPhoneNum
            return
        }
        self.networkUseCase.requestVertification(of: phoneNum) { [weak self] status in
            if status == .SUCCESS {
                self?.phoneAuthStatus = .authNumSent
                self?.waitingForAuthPhoneNum = phoneNum
            } else {
                self?.alertStatus = .withoutPopVC(.networkError)
            }
        }
    }
    
    func requestPhoneAuthAgain() {
        guard let waitingForAuthPhoneNum = waitingForAuthPhoneNum else {
            return
        }
        self.networkUseCase.requestVertification(of: waitingForAuthPhoneNum) { [weak self] status in
            if status == .SUCCESS {
                self?.phoneAuthStatus = .authNumSent
            } else {
                self?.alertStatus = .withoutPopVC(.networkError)
            }
        }
        self.phoneAuthStatus = .authNumSent
    }
    
    func confirmAuthNumber(with authNumber: Int) {
        self.networkUseCase.checkValidity(of: authNumber) {[weak self] confirmed in
            if confirmed {
                self?.phoneAuthStatus = .authComplete
                self?.phonenum = self?.waitingForAuthPhoneNum
                self?.waitingForAuthPhoneNum = nil
            } else {
                self?.phoneAuthStatus = .wrongAuthNumber
            }
        }
    }
    
    func cancelPhoneAuth() {
        self.phoneAuthStatus = nil
        self.waitingForAuthPhoneNum = nil
    }
}

// MARK: Private functions
extension ChangeUserInfoVM {
    private func getUserInfo() {
        SyncUsecase.syncUserDataFromDB { succeed in
            guard succeed else {
                self.alertStatus = .withPopVC(.networkError)
                return
            }
            guard let userInfo = CoreUsecase.fetchUserInfo() else {
                self.alertStatus = .withoutPopVC(.coreDataFetchError)
                return
            }
            self.nickname = userInfo.nickName
            self.phonenum = userInfo.phoneNumber
            self.selectedMajor = userInfo.major
            self.selectedMajorDetail = userInfo.majorDetail
            self.schoolName = userInfo.schoolName
            self.graduationStatus = userInfo.graduationStatus
        }
    }
    
    private func fetchMajorInfo() {
        self.networkUseCase.getMajors { [weak self] majorFetched in
            guard let majorFetched = majorFetched else {
                self?.alertStatus = .withoutPopVC(.networkError)
                return
            }
            self?.majorWithDetail = majorFetched.reduce(into: [:]) { result, next in
                result[next.name] = next.details
            }
            self?.majors = majorFetched.map(\.name)
            if let selectedMajor = self?.selectedMajor,
               let majorDetails = self?.majorWithDetail[selectedMajor] {
                self?.majorDetails = majorDetails
            } else if let major = self?.majors?.first {
                self?.majorDetails = self?.majorWithDetail[major]
            }
        }
    }
    
    private func checkIfSubmitAvailable() -> Bool {
        // TODO: 현재 1.0 회원의 경우 nickName, phoneNum이 랜덤값으로 있기는 한 상태이기에 CoreData 상에서 제거하는 로직이 필요, 또는 Random 값인지 판별하기 위한 로직이 필요
        guard [self.nickname, self.phonenum, self.selectedMajor, self.selectedMajorDetail, self.schoolName, self.graduationStatus].allSatisfy({ $0 != nil && $0 != "" }) else {
            self.alertStatus = .withoutPopVC(.incomplateData)
            return false
        }
        return true
    }
    
    private func saveUserInfoToCoreData(userInfo: UserCoreData) {
        guard self.checkIfSubmitAvailable() else { return }
        
        userInfo.setValue(self.nickname, forKey: "nickName")
        userInfo.setValue(self.phonenum, forKey: "phoneNumber")
        userInfo.setValue(self.selectedMajor, forKey: "major")
        userInfo.setValue(self.selectedMajorDetail, forKey: "majorDetail")
        userInfo.setValue(self.schoolName, forKey: "schoolName")
        userInfo.setValue(self.graduationStatus, forKey: "graduationStatus")
        CoreDataManager.saveCoreData()
    }
    
    private func sendUserInfoToNetwork(userInfo: UserCoreData, completion: @escaping (Bool) -> Void) {
        guard self.checkIfSubmitAvailable() else { return }
        self.networkUseCase.putUserInfoUpdate(userInfo: userInfo) { status in
            switch status {
            case .SUCCESS:
                completion(true)
            default:
                completion(false)
            }
        }
    }
    
    private func updateVersionIfDataUpdateSucceed() {
        // TODO: 1.0 랜덤데이터가 사라졌다는 가정하에
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? String.currentVersion
        UserDefaultsManager.set(to: version, forKey: .userVersion)
        print("userVersion 업데이트 완료")
    }
}
