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
    private var majorWithDetail: [String: [String]] = [:]
    private var waitingForAuthPhoneNum: String?
    
    init(networkUseCase: ChangeUserInfoNetworkUseCase) {
        self.networkUseCase = networkUseCase
        self.getUserInfo()
        self.fetchMajorInfo()
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
        self.saveUserInfoToDB(userInfo: userInfo)
        self.sendUserInfoToNetwork(userInfo: userInfo)
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
             guard let userInfo = CoreUsecase.fetchUserInfo() else { return }
             self.nickname = userInfo.nickName
             self.phonenum = userInfo.phoneNumber
             self.selectedMajor = userInfo.major
             self.selectedMajorDetail = userInfo.majorDetail
             self.schoolName = userInfo.schoolName
             self.graduationStatus = userInfo.graduationStatus
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
            if let selectedMajor = self?.selectedMajor, let majorDetails = self?.majorWithDetail[selectedMajor] {
                self?.majorDetails = majorDetails
            }
        }
    }
    
    private func checkIfSubmitAvailable() -> Bool {
        guard [self.nickname, self.phonenum, self.selectedMajor, self.selectedMajorDetail, self.schoolName, self.graduationStatus].allSatisfy({ $0 != nil && $0 != "" }) else {
            self.alertStatus = .withoutPopVC(.incomplateData)
            return false
        }
        guard let selectedMajor = self.selectedMajor, let selectedMajorDetail = self.selectedMajorDetail else { return false }
        guard self.majorWithDetail[selectedMajor]?.contains(selectedMajorDetail) == true else {
            self.alertStatus = .withoutPopVC(.majorDetailNotSelected)
            return false
        }
        return true
    }
    
    private func saveUserInfoToDB(userInfo: UserCoreData) {
        guard self.checkIfSubmitAvailable() else { return }
        userInfo.setValue(self.nickname, forKey: "nickName")
        userInfo.setValue(self.phonenum, forKey: "phoneNumber")
        userInfo.setValue(self.selectedMajor, forKey: "major")
        userInfo.setValue(self.selectedMajorDetail, forKey: "majorDetail")
        userInfo.setValue(self.schoolName, forKey: "schoolName")
        userInfo.setValue(self.graduationStatus, forKey: "graduationStatus")
        CoreDataManager.saveCoreData()
    }
    
    private func sendUserInfoToNetwork(userInfo: UserCoreData) {
        guard self.checkIfSubmitAvailable() else { return }
        self.networkUseCase.putUserInfoUpdate(userInfo: userInfo) { [weak self] status in
            switch status {
            case .SUCCESS:
                self?.alertStatus = .withPopVC(.saveSuccess)
            default:
                self?.alertStatus = .withoutPopVC(.networkError)
            }
        }
    }
}