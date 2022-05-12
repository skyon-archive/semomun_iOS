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
    
    @Published private(set) var majors: [String] = []
    @Published private(set) var majorDetails: [String] = []
    @Published var configureUIForNicknamePhoneRequest = false
    
    /// VC에서 수정의 대상이 되며 DB로 보내지는 UserInfo
    @Published private(set) var newUserInfo: UserInfo? {
        didSet {
            self.status = self.newUserInfo?.isValid == true ? .userInfoComplete : .userInfoIncomplete
        }
    }
    
    /// 현재 DB에 존재하는 UserInfo
    @Published private(set) var currentUserInfo: UserInfo?
    
    private var majorWithDetail: [String: [String]] = [:]
    /// 가장 최신에 인증이 완료된 전화번호
    private var latestAuthedPhoneNumber: String?
    
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
    func checkUsernameFormat(_ username: String) -> Bool {
        if username.isValidUsernameDuringTyping {
            self.status = .usernameValid
            return true
        } else {
            self.status = .usernameInvalid
            return false
        }
    }
    
    /// 사용자가 입력하는 중에도 확인할 수 있는 전화번호 포맷들을 확인합니다. e.g. 사용할 수 없는 문자
    func checkPhoneNumberFormat(_ phoneNumber: String) -> Bool {
        if phoneNumber.isNumber && phoneNumber.count <= 11 {
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
        
        // 기존과 같은 이름이면 서버 통신시 중복 결과가 나오기 때문에 예외 처리
        guard username != self.currentUserInfo?.username else {
            self.newUserInfo?.username = username
            self.status = .usernameAvailable
            return
        }
        
        self.networkUseCase.usernameAvailable(username) { [weak self] status, isAvailable in
            if status == .SUCCESS {
                if isAvailable {
                    self?.newUserInfo?.username = username
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
        self.newUserInfo?.major = majorName
        if let majorDetails = self.majorWithDetail[majorName] {
            self.majorDetails = majorDetails
        }
        self.newUserInfo?.majorDetail = nil
    }
    
    func selectMajorDetail(at index: Int) {
        guard let majorDetailName = self.majorDetails[safe: index] else { return }
        self.newUserInfo?.majorDetail = majorDetailName
    }
    
    func selectSchool(_ school: String) {
        self.newUserInfo?.school = school
    }
    
    func selectGraduationStatus(_ graduationStatus: String) {
        self.newUserInfo?.graduationStatus = graduationStatus
    }
    
    func submit(completion: @escaping (Bool) -> Void) {
        guard self.status != .wrongAuthCode,
              self.status != .authCodeSent,
              self.newUserInfo?.isValid == true else {
            self.alert = .insufficientData
            completion(false)
            return
        }
        self.sendUserInfoToNetwork { status in
            if status {
                self.saveUserInfoToCoreData()
                completion(true)
            } else {
                self.alert = .networkErrorWithoutPop
                completion(false)
            }
        }
    }
    
    func invalidateUsername() {
        self.newUserInfo?.username = nil
    }
    
    func invalidatePhonenumber() {
        self.newUserInfo?.phoneNumber = nil
    }
}

// 전화 인증 관련 메소드
extension ChangeUserInfoVM {
    func requestPhoneAuth(withPhoneNumber phoneNumber: String) {
        self.newUserInfo?.phoneNumber = nil
        self.phoneAuthenticator.sendSMSCode(to: phoneNumber) { result in
            switch result {
            case .success(_):
                self.status = .authCodeSent
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
                self.newUserInfo?.phoneNumber = phoneNumber
                self.latestAuthedPhoneNumber = phoneNumber
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
        self.newUserInfo?.phoneNumber = self.latestAuthedPhoneNumber
    }
}

// MARK: Private functions
extension ChangeUserInfoVM {
    private func getUserInfo(completion: @escaping () -> Void) {
        SyncUsecase(networkUsecase: self.networkUseCase).syncUserDataFromDB { result in
            switch result {
            case .success(let userInfo):
                self.currentUserInfo = userInfo
                self.newUserInfo = userInfo
                self.latestAuthedPhoneNumber = userInfo.phoneNumber
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
    
    /// 이전 버전에서 와 전화번호가 없는(옳지 않은 형식인) 사용자인 경우를 처리
    private func configurePhoneNumberIfNeeded(_ userCoreData: UserCoreData) {
        if userCoreData.phoneNumber?.isValidPhoneNumber != true {
            self.currentUserInfo?.phoneNumber = nil
            self.newUserInfo?.phoneNumber = nil
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
            if let selectedMajor = self?.currentUserInfo?.major,
               let majorDetails = self?.majorWithDetail[selectedMajor] {
                self?.majorDetails = majorDetails
            }
        }
    }
    
    private func sendUserInfoToNetwork(completion: @escaping (Bool) -> Void) {
        guard let userInfo = self.newUserInfo else {
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
        guard let userInfo = self.newUserInfo else {
            return
        }
        guard let userCoreData = CoreUsecase.fetchUserInfo() else { return }
        userCoreData.setValues(userInfo: userInfo)
        CoreDataManager.saveCoreData()
    }
}
