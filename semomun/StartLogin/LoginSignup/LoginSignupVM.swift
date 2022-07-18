//
//  LoginSignupVM.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/03/09.
//

import Foundation
import Combine

final class LoginSignupVM {
    @Published private(set) var status: LoginSignupStatus?
    @Published private(set) var alert: LoginSignupAlert?
    @Published private(set) var majors: [String] = []
    @Published private(set) var majorDetails: [String] = []
    
    private(set) var signupUserInfo = SignupUserInfo() {
        didSet {
            self.status = self.signupUserInfo.isValid ? .userInfoComplete : .userInfoIncomplete
        }
    }
    
    /// 전화번호 인증이 완료되었는지 여부
    private(set) var canChangePhoneNumber = true
    
    private var majorWithDetail: [String: [String]] = [:]
    
    private let networkUseCase: LoginSignupVMNetworkUsecase
    private let phoneAuthenticator: PhoneAuthenticator
    
    var selectedMajor: String? {
        return self.signupUserInfo.major
    }
    
    var selectedMajorDetail: String? {
        return self.signupUserInfo.majorDetail
    }
    
    init(networkUseCase: LoginSignupVMNetworkUsecase) {
        self.networkUseCase = networkUseCase
        self.phoneAuthenticator = PhoneAuthenticator(networkUsecase: networkUseCase)
        self.fetchMajorInfo()
    }
    
    func checkUsernameFormat(_ username: String) -> Bool {
        if username.isValidUsernameDuringTyping {
            self.status = .usernameValid
            return true
        } else {
            self.status = .usernameInvalid
            return false
        }
    }
    
    func checkPhoneNumberFormat(_ phoneNumber: String) -> Bool {
        if phoneNumber.isNumber && phoneNumber.count < 12 {
            self.status = .phoneNumberValid
            return true
        } else {
            self.status = .phoneNumberInvalid
            return false
        }
    }
    
    func changeUsername(_ username: String) {
        guard username.isValidUsername else {
            self.status = .usernameInvalid
            return
        }
        self.networkUseCase.usernameAvailable(username) { [weak self] status, isAvailable in
            if status == .SUCCESS {
                if isAvailable {
                    self?.signupUserInfo.username = username
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
        self.signupUserInfo.major = majorName
        if let majorDetails = self.majorWithDetail[majorName] {
            self.majorDetails = majorDetails
        }
        self.signupUserInfo.majorDetail = nil
    }
    
    func selectMajorDetail(at index: Int) {
        guard let majorDetailName = self.majorDetails[safe: index] else { return }
        self.signupUserInfo.majorDetail = majorDetailName
    }
    
    func selectSchool(_ school: String) {
        self.signupUserInfo.school = school
    }
    
    func selectGraduationStatus(_ graduationStatus: String) {
        self.signupUserInfo.graduationStatus = graduationStatus
    }
    
    func updateFavoriteTags() {
        if let tagsData = UserDefaultsManager.favoriteTags,
           let tags = try? PropertyListDecoder().decode([TagOfDB].self, from: tagsData) {
            self.signupUserInfo.favoriteTags = tags.map(\.tid)
        }
    }
    
    /// username에 변화가 있는 경우 기존에 있던(예전에 중복확인을 한) username을 무효화
    func invalidateUsername() {
        self.signupUserInfo.username = nil
    }
}

// MARK: 전화 인증 관련 메소드
extension LoginSignupVM {
    func requestPhoneAuth(withPhoneNumber phoneNumber: String) {
        guard phoneNumber.isValidPhoneNumber else {
            self.status = .phoneNumberInvalid
            return
        }
        self.phoneAuthenticator.sendSMSCode(to: phoneNumber) { result in
            switch result {
            case .success(_):
                self.status = .authCodeSent
                self.canChangePhoneNumber = false
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
                guard let phoneNumberWithCountryCode = phoneNumber.phoneNumberWithCountryCode else {
                    self.alert = .networkErrorWithoutPop
                    return
                }
                self.signupUserInfo.phone = phoneNumberWithCountryCode
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
        self.canChangePhoneNumber = true
        self.signupUserInfo.phone = nil
    }
}

// MARK: Private functions
extension LoginSignupVM {
    private func fetchMajorInfo() {
        self.networkUseCase.getMajors { [weak self] majorFetched in
            guard let majorFetched = majorFetched else {
                self?.alert = .networkErrorWithPop
                return
            }
            self?.majors = majorFetched.map(\.name)
            self?.majorWithDetail = majorFetched.reduce(into: [:]) { result, next in
                result[next.name] = next.details
            }
            if let firstMajorName = self?.majors.first,
               let firstMajorDetail = self?.majorWithDetail[firstMajorName] {
                self?.majorDetails = firstMajorDetail
            }
        }
    }
}
