//
//  ChangeUserInfoVM.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/29.
//

import Foundation
import Combine

typealias ChangeUserInfoNetworkUseCase = (MajorFetchable & UserInfoSendable & UsernameCheckable & PhonenumVerifiable & SyncFetchable)

final class ChangeUserInfoVM {
    @Published private(set) var status: LoginSignupStatus?
    @Published private(set) var alert: LoginSignupAlert?
    @Published private(set) var userInfo: UserInfo?
    
    @Published private(set) var majors: [String] = []
    @Published private(set) var majorDetails: [String] = []
    @Published var configureUIForNicknamePhoneRequest = false
    
    private var majorWithDetail: [String: [String]] = [:]
    // VC에 진입하는 순간 DB에 존재하는 사용자의 username 값
    private var currentUserName: String?
    
    private let networkUseCase: ChangeUserInfoNetworkUseCase
    private let phoneAuthenticator: PhoneAuthenticator
    
    init(networkUseCase: ChangeUserInfoNetworkUseCase) {
        self.networkUseCase = networkUseCase
        self.phoneAuthenticator = PhoneAuthenticator(networkUsecase: networkUseCase)
    }
    
    func fetchData() {
        self.getUserInfo { [weak self] in
            self?.fetchMajorInfo()
        }
    }
    
    /// 사용자가 입력하는 중에도 확인할 수 있는 username 포맷들을 확인합니다. e.g. 사용할 수 없는 문자
    func checkUsernameFormat(_ username: String) {
        self.status = username.isValidUsernameDuringTyping ? .usernameGoodFormat : .usernameWrongFormat
    }
    
    /// 사용자가 입력하는 중에도 확인할 수 있는 전화번호 포맷들을 확인합니다. e.g. 사용할 수 없는 문자
    func checkPhoneNumberFormat(_ phoneNumber: String) {
        self.status = phoneNumber.isNumber && phoneNumber.count <= 11 ? .phoneNumberGoodFormat : .phoneNumberWrongFormat
    }
    
    func changeUsername(_ username: String) {
        guard username.isValidUsername else {
            self.status = .usernameWrongFormat
            return
        }
        
        // 기존과 같은 이름이면 서버 통신 안함
        guard username != self.currentUserName else {
            self.userInfo?.username = username
            self.status = .usernameAvailable
            return
        }
        
        self.networkUseCase.usernameAvailable(username) { [weak self] status, isAvailable in
            if status == .SUCCESS {
                if isAvailable {
                    self?.userInfo?.username = username
                    self?.status = .usernameAvailable
                } else {
                    self?.status = .usernameAlreadyUsed
                }
            } else {
                self?.alert = .networkErrorWithoutPop
            }
        }
    }
    
    func selectMajor(at index: Int) {
        guard let majorName = self.majors[safe: index] else { return }
        self.userInfo?.major = majorName
        if let majorDetails = self.majorWithDetail[majorName] {
            self.majorDetails = majorDetails
        }
        self.userInfo?.majorDetail = nil
    }
    
    func selectMajorDetail(at index: Int) {
        guard let majorDetailName = self.majorDetails[safe: index] else { return }
        self.userInfo?.majorDetail = majorDetailName
    }
    
    func selectSchool(_ school: String) {
        self.userInfo?.school = school
    }
    
    func selectGraduationStatus(_ graduationStatus: String) {
        self.userInfo?.graduationStatus = graduationStatus
    }
    
    func submit(completionWhenSucceed: @escaping () -> Void) {
        guard self.status != .wrongAuthCode,
              self.status != .authCodeSent,
              self.userInfo?.isValid == true else {
                  self.alert = .insufficientData
                  return
              }
        self.sendUserInfoToNetwork { status in
            if status {
                self.saveUserInfoToCoreData()
                completionWhenSucceed()
            } else {
                self.alert = .networkErrorWithoutPop
            }
        }
    }
}

// 전화 인증 관련 메소드
extension ChangeUserInfoVM {
    func requestPhoneAuth(withPhoneNumber phoneNumber: String) {
        self.phoneAuthenticator.sendSMSCode(to: phoneNumber) { result in
            switch result {
            case .success(_):
                self.status = .authCodeSent
                self.alert = .codeSentAlert
            case .failure(let error):
                switch error {
                case .noNetwork:
                    self.alert = .networkErrorWithoutPop
                case .invalidPhoneNumber:
                    assertionFailure()
                case .smsSentTooMuch:
                    self.alert = .snsLimitExceedAlert
                }
            }
        }
    }
    
    func confirmAuthNumber(with code: String) {
        self.phoneAuthenticator.verifySMSCode(code) { result in
            switch result {
            case .success(let phoneNumber):
                self.userInfo?.phoneNumber = phoneNumber
                self.status = .authComplete
            case .failure(let error):
                switch error {
                case .wrongCode:
                    self.status = .wrongAuthCode
                case .noNetwork:
                    self.alert = .networkErrorWithoutPop
                case .codeNotSent:
                    assertionFailure()
                }
            }
        }
    }
    
    func requestAuthAgain() {
        self.phoneAuthenticator.resendSMSCode { result in
            switch result {
            case .success(_):
                self.status = .authCodeSent
                self.alert = .codeSentAlert
            case .failure(let error):
                switch error {
                case .noNetwork:
                    self.alert = .networkErrorWithoutPop
                case .smsSentTooMuch:
                    self.alert = .snsLimitExceedAlert
                }
            }
        }
    }
    
    func cancelAuth() {
        self.status = nil
    }
}

// MARK: Private functions
extension ChangeUserInfoVM {
    private func getUserInfo(completion: @escaping () -> Void) {
        SyncUsecase(networkUsecase: self.networkUseCase).syncUserDataFromDB { result in
            switch result {
            case .success(let userInfo):
                self.userInfo = userInfo
                self.currentUserName = userInfo.username
            case .failure(_):
                self.alert = .networkErrorWithPop
                completion()
                return
            }
            
            guard let userCoreData = CoreUsecase.fetchUserInfo() else {
                self.alert = .networkErrorWithPop
                return
            }
            
            self.configurePhoneNumberIfNeeded(userCoreData)
            completion()
        }
    }
    
    private func configurePhoneNumberIfNeeded(_ userCoreData: UserCoreData) {
        if userCoreData.phoneNumber?.isValidPhoneNumber != true {
            self.userInfo?.phoneNumber = nil
            self.configureUIForNicknamePhoneRequest = true
        }
    }
    
    private func fetchMajorInfo() {
        self.networkUseCase.getMajors { [weak self] majorFetched in
            guard let majorFetched = majorFetched else {
                self?.alert = .networkErrorWithPop
                return
            }
            self?.majors = majorFetched.map(\.name)
            self?.majorWithDetail = majorFetched.reduce(into: [:]) { majorWithDetail, major in
                majorWithDetail[major.name] = major.details
            }
            if let selectedMajor = self?.userInfo?.major,
               let majorDetails = self?.majorWithDetail[selectedMajor] {
                self?.majorDetails = majorDetails
            }
        }
    }
    
    private func sendUserInfoToNetwork(completion: @escaping (Bool) -> Void) {
        guard let userInfo = self.userInfo else {
            completion(false)
            return
        }
        self.networkUseCase.putUserInfoUpdate(userInfo: userInfo) { status in
            switch status {
            case .SUCCESS:
                completion(true)
            default:
                completion(false)
            }
        }
    }
    
    private func saveUserInfoToCoreData() {
        guard let userInfo = self.userInfo else {
            return
        }
        guard let userCoreData = CoreUsecase.fetchUserInfo() else { return }
        userCoreData.setValues(userInfo: userInfo)
        CoreDataManager.saveCoreData()
    }
}
