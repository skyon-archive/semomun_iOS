//
//  LoginSignupVM.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/03/09.
//

import Foundation
import Combine

typealias LoginSignupVMNetworkUsecase = (MajorFetchable & UserInfoSendable & NicknameCheckable & PhonenumVerifiable)

final class LoginSignupVM {
    @Published private(set) var status: LoginSignupStatus?
    @Published private(set) var alert: LoginSignupAlert?
    @Published private(set) var majors: [String] = []
    @Published private(set) var majorDetails: [String] = []
    
    private(set) var signupUserInfo = SignupUserInfo()
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
    
    func changeUsername(_ username: String) {
        guard username.isEmpty == false else { return }
        self.networkUseCase.checkRedundancy(ofNickname: username) { [weak self] status, isAvailable in
            if status == .SUCCESS {
                if isAvailable {
                    self?.signupUserInfo.username = username
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
}

// MARK: 전화 인증 관련 메소드
extension LoginSignupVM {
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
                self.signupUserInfo.phone = phoneNumber
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
                }
            }
        }
    }
    
    func cancelAuth() {
        self.status = nil
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

