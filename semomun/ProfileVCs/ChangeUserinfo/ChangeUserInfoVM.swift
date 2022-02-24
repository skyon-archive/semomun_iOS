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
    
    enum ChangeNicknameStatus {
        case success
        case fail
    }
    
    enum PhoneAuthStatus {
        case authNumSent
        case authComplete
        case wrongAuthNumber
        case invaildPhoneNum
    }
    
    @Published private(set) var alertStatus: ChangeUserInfoAlert?
    @Published private(set) var changeNicknameStatus: ChangeNicknameStatus?
    @Published private(set) var phoneAuthStatus: PhoneAuthStatus?
    
    @Published private(set) var nickname: String?
    @Published private(set) var phonenum: String?
    @Published private(set) var majors: [String] = []
    @Published private(set) var majorDetails: [String] = []
    @Published var schoolName: String?
    @Published var graduationStatus: String?
    @Published var configureUIForNicknamePhoneRequest = false
    
    private var majorWithDetail: [String: [String]] = [:]
    private(set) var selectedMajor: String?
    private(set) var selectedMajorDetail: String?
    
    private let networkUseCase: ChangeUserInfoNetworkUseCase
    private let isSignup: Bool
    private var tempPhoneNum: String?
    
    init(networkUseCase: ChangeUserInfoNetworkUseCase, isSignup: Bool) {
        self.networkUseCase = networkUseCase
        self.isSignup = isSignup
        if isSignup {
            self.fetchMajorInfo()
        } else {
            self.getUserInfo { [weak self] in
                self?.fetchMajorInfo()
            }
        }
    }
    
    func changeNicknameIfAvailable(nickname: String) {
        self.networkUseCase.checkRedundancy(ofNickname: nickname) { [weak self] status, isAvailable in
            if status == .SUCCESS {
                if isAvailable {
                    self?.nickname = nickname
                    self?.changeNicknameStatus = .success
                } else {
                    self?.changeNicknameStatus = .fail
                }
            } else {
                self?.alertStatus = .withoutPopVC(.networkError)
            }
        }
    }
    
    func selectMajor(at index: Int) {
        guard let majorName = self.majors[safe: index] else { return }
        self.selectedMajor = majorName
        if let majorDetails = self.majorWithDetail[majorName] {
            self.majorDetails = majorDetails
        }
        self.selectedMajorDetail = nil
    }
    
    func selectMajorDetail(at index: Int) {
        guard let majorDetailName = self.majorDetails[safe: index] else { return }
        self.selectedMajorDetail = majorDetailName
    }
    
    func submitUserInfo() {
        let userInfo = self.makeUserInfo()
        self.sendUserInfoToNetwork(userInfo: userInfo) { [weak self] isSuccess in
            if isSuccess {
                self?.saveUserInfoToCoreData(userInfo: userInfo)
                self?.alertStatus = .withPopVC(.saveSuccess)
            } else {
                self?.alertStatus = .withoutPopVC(.networkError)
            }
        }
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
}

// 전화 인증 관련 메소드
extension ChangeUserInfoVM {
    func requestPhoneAuth(withPhoneNumber phoneNum: String) {
        guard phoneNum.count == 11 else {
            self.phoneAuthStatus = .invaildPhoneNum
            return
        }
        self.networkUseCase.requestVertification(of: phoneNum) { [weak self] status in
            if status == .SUCCESS {
                self?.phoneAuthStatus = .authNumSent
                self?.tempPhoneNum = phoneNum
            } else {
                self?.alertStatus = .withoutPopVC(.networkError)
            }
        }
    }
    
    /// 재인증 요청
    func requestPhoneAuthAgain() {
        guard let tempPhoneNum = tempPhoneNum else { return }
        self.networkUseCase.requestVertification(of: tempPhoneNum) { [weak self] status in
            if status == .SUCCESS {
                self?.phoneAuthStatus = .authNumSent
            } else {
                self?.alertStatus = .withoutPopVC(.networkError)
            }
        }
        self.phoneAuthStatus = .authNumSent
    }
    
    func confirmAuthNumber(with authNumber: String) {
        self.networkUseCase.checkValidity(of: authNumber) {[weak self] confirmed in
            if confirmed {
                self?.phoneAuthStatus = .authComplete
                self?.phonenum = self?.tempPhoneNum
                self?.tempPhoneNum = nil
            } else {
                self?.phoneAuthStatus = .wrongAuthNumber
            }
        }
    }
    
    /// 인증 취소
    func cancelPhoneAuth() {
        self.phoneAuthStatus = nil
        self.tempPhoneNum = nil
    }
}

// MARK: Private functions
extension ChangeUserInfoVM {
    private func getUserInfo(completion: @escaping () -> Void) {
        SyncUsecase.syncUserDataFromDB { succeed in
            guard succeed else {
                self.alertStatus = .withPopVC(.networkError)
                completion()
                return
            }
            guard let userInfo = CoreUsecase.fetchUserInfo() else {
                self.alertStatus = .withoutPopVC(.coreDataFetchError)
                completion()
                return
            }
            self.nickname = userInfo.nickName
            self.phonenum = userInfo.phoneNumber
            self.selectedMajor = userInfo.major
            self.selectedMajorDetail = userInfo.majorDetail
            self.schoolName = userInfo.schoolName
            self.graduationStatus = userInfo.graduationStatus
            self.configureUIForNicknamePhoneRequestIfNeeded(userInfo)
            completion()
        }
    }
    
    private func configureUIForNicknamePhoneRequestIfNeeded(_ userCoreData: UserCoreData) {
        if userCoreData.phoneNumber == nil {
            self.phonenum = ""
            self.configureUIForNicknamePhoneRequest = true
        }
    }
    
    private func fetchMajorInfo() {
        self.networkUseCase.getMajors { [weak self] majorFetched in
            guard let majorFetched = majorFetched else {
                self?.alertStatus = .withoutPopVC(.networkError)
                return
            }
            self?.majors = majorFetched.map(\.name)
            self?.majorWithDetail = majorFetched.reduce(into: [:]) { majorWithDetail, major in
                majorWithDetail[major.name] = major.details
            }
            if let selectedMajor = self?.selectedMajor,
               let majorDetails = self?.majorWithDetail[selectedMajor] {
                self?.majorDetails = majorDetails
            } else { // 회원가입(선택한 전공이 없는 경우)
                if let firstMajorName = self?.majors.first,
                   let firstMajorDetail = self?.majorWithDetail[firstMajorName] {
                    self?.majorDetails = firstMajorDetail
                }
            }
        }
    }
    
    private func checkIfSubmitAvailable() -> Bool {
        guard [self.nickname, self.phonenum, self.selectedMajor, self.selectedMajorDetail, self.schoolName, self.graduationStatus].allSatisfy({ $0 != nil && $0 != "" }) else {
            self.alertStatus = .withoutPopVC(.incomplateData)
            return false
        }
        return true
    }
    
    private func sendUserInfoToNetwork(userInfo: UserInfo, completion: @escaping (Bool) -> Void) {
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
    
    private func saveUserInfoToCoreData(userInfo: UserInfo) {
        guard self.checkIfSubmitAvailable() else { return }
        guard let userCoreData = CoreUsecase.fetchUserInfo() else { return }
        userCoreData.setValue(self.nickname, forKey: "nickName")
        userCoreData.setValue(self.phonenum, forKey: "phoneNumber")
        userCoreData.setValue(self.selectedMajor, forKey: "major")
        userCoreData.setValue(self.selectedMajorDetail, forKey: "majorDetail")
        userCoreData.setValue(self.schoolName, forKey: "schoolName")
        userCoreData.setValue(self.graduationStatus, forKey: "graduationStatus")
        CoreDataManager.saveCoreData()
    }
}
