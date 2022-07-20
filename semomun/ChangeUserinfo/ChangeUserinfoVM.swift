//
//  ChangeUserinfoVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/19.
//

import Foundation
import Combine

typealias ChangeUserInfoNetworkUseCase = (UserInfoSendable & UsernameCheckable & PhonenumVerifiable & SyncFetchable)

final class ChangeUserinfoVM {
    /* public */
    @Published private(set) var status: LoginSignupStatus?
    @Published private(set) var alert: LoginSignupAlert?
    @Published private(set) var majorDetails: [String] = []
    /// 현재 DB에 존재하는 UserInfo
    @Published private(set) var currentUserInfo: UserInfo?
    /// VC에서 수정의 대상이 되며 DB로 보내지는 UserInfo
    @Published private(set) var newUserInfo: UserInfo? {
        didSet {
            self.isChanged = true
            self.status = self.validResult ? .userInfoComplete : .userInfoIncomplete
        }
    }
    @Published private(set) var updateUserinfoSuccess: Bool = false
    private(set) var isChanged: Bool = false {
        didSet {
            self.status = self.validResult ? .userInfoComplete : .userInfoIncomplete
        }
    }
    var validResult: Bool {
        return self.newUserInfo?.isValid == true && self.isChanged == true
    }
    let majorRawValues: [[String]] = [
        ["인문", "상경", "사회", "교육", "기타"],
        ["공학", "자연", "의약", "생활과학", "기타"],
        ["미술", "음악", "체육", "기타"]
    ]
    /* private */
    private let networkUseCase: ChangeUserInfoNetworkUseCase
    private let phoneAuthenticator: PhoneAuthenticator
    
    init(networkUseCase: ChangeUserInfoNetworkUseCase) {
        self.networkUseCase = networkUseCase
        self.phoneAuthenticator = PhoneAuthenticator(networkUsecase: networkUseCase)
    }
    /// VC 에서 fetch 후 시작
    func getUserInfo() {
        SyncUsecase(networkUsecase: self.networkUseCase).syncUserDataFromDB { [weak self] result in
            switch result {
            case .success(let userInfo):
                self?.currentUserInfo = userInfo
                self?.newUserInfo = userInfo
            case .failure(_):
                self?.alert = .networkError
            }
            
            guard let userCoreData = CoreUsecase.fetchUserInfo() else {
                self?.alert = .networkError
                return
            }
            
            if userCoreData.phoneNumber?.isValidPhoneNumber != true {
                self?.currentUserInfo?.phoneNumber = nil
                self?.newUserInfo?.phoneNumber = nil
            }
            
            self?.isChanged = false
            self?.status = .userInfoIncomplete
        }
    }
    /// 첫 majorDetails 값 설정
    func configureMajorDetails(majorIndex: Int) {
        self.majorDetails = self.majorRawValues[majorIndex]
    }
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
        self.phoneAuthenticator.sendSMSCode(to: phoneNumber) { [weak self] result in
            switch result {
            case .success(_):
                self?.status = .authCodeSent
            case .failure(let error):
                switch error {
                case .noNetwork:
                    self?.alert = .networkError
                case .invalidPhoneNumber:
                    assertionFailure()
                case .smsSentTooMuch:
                    self?.status = .smsLimitExceed
                }
            }
        }
    }
    /// 인증번호 확인
    func confirmAuthNumber(with code: String) {
        self.phoneAuthenticator.verifySMSCode(code) { [weak self] result in
            switch result {
            case .success(let phoneNumber):
                guard let phoneNumberWithCountryCode = phoneNumber.phoneNumberWithCountryCode else {
                    self?.alert = .networkError
                    return
                }
                // 전화번호 형식수정 후 반영
                self?.newUserInfo?.phoneNumber = phoneNumberWithCountryCode
                self?.status = .authComplete
            case .failure(let error):
                switch error {
                case .wrongCode:
                    self?.status = .wrongAuthCode
                case .noNetwork:
                    self?.alert = .networkError
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
                    self?.newUserInfo?.username = id
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
        self.newUserInfo?.username = self.currentUserInfo?.username
    }
    /// Major 선택 -> MajorDetail 내용 변경, Major, MajorDetail 초기화 반영
    func selectMajor(to index: Int) {
        self.majorDetails = self.majorRawValues[index]
        self.newUserInfo?.major = nil
        self.newUserInfo?.majorDetail = nil
    }
    /// MajorDetail 선택, Major, MajorDetail 내용 반영
    func selectMajorDetail(major: String, detailIndex: Int) {
        let majorDetail = self.majorDetails[detailIndex]
        self.newUserInfo?.major = major
        self.newUserInfo?.majorDetail = majorDetail
    }
    /// 학교정보 반영
    func selectSchool(_ school: String) {
        self.newUserInfo?.school = school
    }
    /// 졸업여부 반영
    func selectGraduationStatus(_ graduationStatus: String) {
        self.newUserInfo?.graduationStatus = graduationStatus
    }
    /// 변동사항 Network 반영
    func submit() {
        guard self.isChanged == true,
              let userInfo = self.newUserInfo, userInfo.isValid == true else { return }
        
        self.networkUseCase.putUserInfoUpdate(userInfo: userInfo) { [weak self] status in
            guard status == .SUCCESS else {
                self?.alert = .networkError
                return
            }
            self?.saveUserInfoToCoreData()
            self?.updateUserinfoSuccess = true
        }
    }
    
    private func saveUserInfoToCoreData() {
        guard let userInfo = self.newUserInfo else { return }
        guard let userCoreData = CoreUsecase.fetchUserInfo() else { return }
        userCoreData.setValues(userInfo: userInfo)
        CoreDataManager.saveCoreData()
    }
}
