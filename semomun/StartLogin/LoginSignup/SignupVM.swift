//
//  SignupVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/15.
//

import Foundation
import Combine

typealias LoginSignupVMNetworkUsecase = (UsernameCheckable & PhonenumVerifiable)

final class SignupVM {
    @Published private(set) var status: LoginSignupStatus?
    @Published private(set) var alert: LoginSignupAlert?
    @Published private(set) var majorDetails: [String] = []
    @Published private(set) var showSocialSignupVC: Bool = false
    private let networkUseCase: LoginSignupVMNetworkUsecase
    private let phoneAuthenticator: PhoneAuthenticator
    private let majorRawValues: [[String]] = [
        ["인문", "상경", "사회", "교육", "기타"],
        ["공학", "자연", "의약", "생활과학", "기타"],
        ["미술", "음악", "체육", "기타"]
    ]
    private(set) var signupUserInfo = SignupUserInfo() {
        didSet {
            self.status = self.signupUserInfo.isValidForPopupTags ? .userInfoComplete : .userInfoIncomplete
        }
    }
    
    init(networkUseCase: LoginSignupVMNetworkUsecase) {
        self.networkUseCase = networkUseCase
        self.phoneAuthenticator = PhoneAuthenticator(networkUsecase: networkUseCase)
        self.configureNotification()
    }
}

// MARK: Public Functions
extension SignupVM {
    /// 전화번호 전송을 위한 전화번호 형식확인
    func checkPhoneNumberFormat(_ phoneNumber: String) -> Bool {
        if phoneNumber.isNumber && phoneNumber.count > 8 {
            self.status = .phoneNumberValid
            return true
        } else {
            self.status = .phoneNumberInvalid
            return false
        }
    }
    /// 전화번호로 인증번호 전송
    func requestPhoneAuth(withPhoneNumber phoneNumber: String) {
        guard phoneNumber.isValidPhoneNumber else {
            self.status = .phoneNumberInvalid
            return
        }
        self.phoneAuthenticator.sendSMSCode(to: phoneNumber) { result in
            switch result {
            case .success(_):
                self.status = .authCodeSent
            case .failure(let error):
                switch error {
                case .noNetwork:
                    self.alert = .networkError
                case .invalidPhoneNumber:
                    assertionFailure()
                case .smsSentTooMuch:
                    self.status = .smsLimitExceed
                }
            }
        }
    }
    /// 인증번호 확인
    func confirmAuthNumber(with code: String) {
        self.phoneAuthenticator.verifySMSCode(code) { result in
            switch result {
            case .success(let phoneNumber):
                guard let phoneNumberWithCountryCode = phoneNumber.phoneNumberWithCountryCode else {
                    self.alert = .networkError
                    return
                }
                // 전화번호 형식수정 후 반영
                self.signupUserInfo.phone = phoneNumberWithCountryCode
                self.status = .authComplete
            case .failure(let error):
                switch error {
                case .wrongCode:
                    self.status = .wrongAuthCode
                case .noNetwork:
                    self.alert = .networkError
                case .codeNotSent:
                    assertionFailure()
                }
            }
        }
    }
    /// 닉네임 형식 확인 및 중복확인
    func checkIDDuplicated(_ id: String) {
        guard id.isValidUsername else {
            self.status = .usernameInvalid
            return
        }
        self.networkUseCase.usernameAvailable(id) { [weak self] status, isAvailable in
            if status == .SUCCESS {
                if isAvailable {
                    self?.signupUserInfo.username = id
                    self?.status = .usernameAvailable
                } else {
                    self?.status = .usernameAlreadyUsed
                }
            } else {
                self?.alert = .networkError
            }
        }
    }
    /// username에 변화가 있는 경우 기존에 있던(예전에 중복확인을 한) username을 무효화
    func invalidateUsername() {
        self.signupUserInfo.username = nil
    }
    /// Major 선택 -> MajorDetail 내용 변경, Major, MajorDetail 초기화 반영
    func selectMajor(to index: Int) {
        self.majorDetails = self.majorRawValues[index]
        self.signupUserInfo.major = nil
        self.signupUserInfo.majorDetail = nil
    }
    /// MajorDetail 선택, Major, MajorDetail 내용 반영
    func selectMajorDetail(major: String, detailIndex: Int) {
        let majorDetail = self.majorDetails[detailIndex]
        self.signupUserInfo.major = major
        self.signupUserInfo.majorDetail = majorDetail
    }
    /// 학교정보 반영
    func selectSchool(_ school: String) {
        self.signupUserInfo.school = school
    }
    /// 졸업여부 반영
    func selectGraduationStatus(_ graduationStatus: String) {
        self.signupUserInfo.graduationStatus = graduationStatus
    }
    /// 마케팅 반영
    func selectMarketing(to value: Bool) {
        self.signupUserInfo.marketing = value
    }
}

extension SignupVM {
    private func configureNotification() {
        NotificationCenter.default.addObserver(forName: .refreshFavoriteTags, object: nil, queue: .current) { [weak self] _ in
            if let tagsData = UserDefaultsManager.favoriteTags,
               let tags = try? PropertyListDecoder().decode([TagOfDB].self, from: tagsData) {
                self?.signupUserInfo.favoriteTags = tags.map(\.tid)
                self?.showSocialSignupVC = true
            } else {
                self?.signupUserInfo.favoriteTags = []
            }
        }
    }
}
