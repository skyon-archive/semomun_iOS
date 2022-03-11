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
    @Published private(set) var status: LoginSignupStatus?
    @Published private(set) var alert: LoginSignupAlert?
    @Published private(set) var userInfo: UserInfo?
    
    @Published private(set) var majors: [String] = []
    @Published private(set) var majorDetails: [String] = []
    @Published var configureUIForNicknamePhoneRequest = false
    
    private var majorWithDetail: [String: [String]] = [:]
    
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
    
    func changeUsername(_ username: String) {
        guard username.isEmpty == false else { return }
        self.networkUseCase.checkRedundancy(ofNickname: username) { [weak self] status, isAvailable in
            if status == .SUCCESS {
                if isAvailable {
                    self?.userInfo?.username = username
                    self?.status = .usernameAvailable
                } else {
                    self?.status = .usernameInavailable
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
        guard self.status != .codeWrong,
              self.status != .codeSent,
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
                self.status = .codeSent
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
                self.status = .codeAuthComplete
            case .failure(let error):
                switch error {
                case .wrongCode:
                    self.status = .codeWrong
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
                self.status = .codeSent
                self.alert = .codeSentAlert
            case .failure(let error):
                switch error {
                case .noNetwork:
                    self.alert = .networkErrorWithoutPop
                case .smsSentTooMuch:
                    self.alert = .snsLimitExceedAlert
                case .didNotSend:
                    assertionFailure()
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
        SyncUsecase.syncUserDataFromDB { result in
            switch result {
            case .success(let userInfo):
                self.userInfo = userInfo
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
                self?.alert = .networkErrorWithoutPop
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
