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
        case cancel
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
    }
    
    func fetchData() {
        if self.isSignup {
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
        guard let userInfo = self.makeUserInfo() else {
            self.alertStatus = .withoutPopVC(.incomplateData)
            return
        }
        self.sendUserInfoToNetwork(userInfo: userInfo) { [weak self] isSuccess in
            if isSuccess {
                self?.saveUserInfoToCoreData(userInfo: userInfo)
                self?.alertStatus = .withPopVC(.saveSuccess)
            } else {
                self?.alertStatus = .withoutPopVC(.networkError)
            }
        }
    }
    
    func makeUserInfo() -> UserInfo? {
        guard self.checkDataValidity(),
              let uid = CoreUsecase.fetchUserInfo()?.uid else { return nil }
        var userInfo = UserInfo(uid: Int(uid) ?? 0)
        userInfo.username = self.nickname
        userInfo.phoneNumber = self.phonenum
        userInfo.major = self.selectedMajor
        userInfo.majorDetail = self.selectedMajorDetail
        userInfo.school = self.schoolName
        userInfo.graduationStatus = self.graduationStatus
        return userInfo
    }
    
    func makeSignupUserInfo() -> SignupUserInfo? {
        guard let nickname = self.nickname,
              let phone = self.phonenum?.phoneNumberWithCountryCode,
              let school = self.schoolName,
              let major = self.selectedMajor,
              let majorDetail = self.selectedMajorDetail,
              let graduationStatus = self.graduationStatus else { return nil }
        return SignupUserInfo(
            username: nickname,
            phone: phone,
            school: school,
            major: major,
            majorDetail: majorDetail,
            favoriteTags: [1, 2], // TODO: tid 반영
            graduationStatus: graduationStatus
        )
    }
}

// 전화 인증 관련 메소드
extension ChangeUserInfoVM {
    func requestPhoneAuth(withPhoneNumber phoneNum: String) {
        guard let phoneNumber = phoneNum.phoneNumberWithCountryCode else {
            self.phoneAuthStatus = .invaildPhoneNum
            return
        }
        self.networkUseCase.requestVertification(of: phoneNumber) { [weak self] status in
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
        guard let tempPhoneNum = self.tempPhoneNum?.phoneNumberWithCountryCode else { return }
        self.networkUseCase.requestVertification(of: tempPhoneNum) { [weak self] status in
            if status == .SUCCESS {
                self?.phoneAuthStatus = .authNumSent
            } else {
                self?.alertStatus = .withoutPopVC(.networkError)
            }
        }
    }
    
    func confirmAuthNumber(with authNumber: String) {
        guard let tempPhoneNum = self.tempPhoneNum?.phoneNumberWithCountryCode else { return }
//        self.networkUseCase.checkValidity(phoneNumber: tempPhoneNum, code: authNumber) {[weak self] confirmed in
//            if confirmed {
//                self?.phoneAuthStatus = .authComplete
//                self?.phonenum = self?.tempPhoneNum
//                self?.tempPhoneNum = nil
//            } else {
//                self?.phoneAuthStatus = .wrongAuthNumber
//            }
//        }
    }
    
    /// 인증 취소
    func cancelPhoneAuth() {
        self.phoneAuthStatus = .cancel
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
        if userCoreData.phoneNumber?.isValidPhoneNumber != true {
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
    
    private func checkDataValidity() -> Bool {
        return [self.nickname, self.selectedMajor, self.selectedMajorDetail, self.schoolName, self.graduationStatus].allSatisfy({ $0 != nil && $0 != "" }) && self.phonenum?.isValidPhoneNumber == true
    }
    
    private func sendUserInfoToNetwork(userInfo: UserInfo, completion: @escaping (Bool) -> Void) {
        guard self.checkDataValidity() else {
            self.alertStatus = .withoutPopVC(.incomplateData)
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
    
    private func saveUserInfoToCoreData(userInfo: UserInfo) {
        guard self.checkDataValidity() else {
            self.alertStatus = .withoutPopVC(.incomplateData)
            return
        }
        guard let userCoreData = CoreUsecase.fetchUserInfo() else { return }
        userCoreData.setValues(userInfo: userInfo)
        CoreDataManager.saveCoreData()
    }
}
