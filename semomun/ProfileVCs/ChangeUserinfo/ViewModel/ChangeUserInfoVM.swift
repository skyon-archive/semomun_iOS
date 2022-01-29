//
//  ChangeUserInfoVM.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/29.
//

import Foundation
import Combine

typealias ChangeUserInfoNetworkUseCase = (MajorFetchable & UserInfoSendable)


final class ChangeUserInfoVM {
    
    enum ChangeUserInfoAlert: Error {
        case incompleteData, networkError, coreDataFetchError, success
    }
    
    @Published private(set) var alertStatus: ChangeUserInfoAlert? = nil
    @Published var nickname: String?
    @Published var phonenum: String?
    @Published var schoolName: String?
    @Published var graduationStatus: String?
    @Published private(set) var majors: [String]?
    @Published var majorDetails: [String]?
    @Published var selectedMajor: String?
    @Published var selectedMajorDetail: String?
    
    private let networkUseCase: ChangeUserInfoNetworkUseCase
    private var majorWithDetail: [String: [String]] = [:]
    
    init(networkUseCase: ChangeUserInfoNetworkUseCase) {
        self.networkUseCase = networkUseCase
        self.getUserInfo()
        self.fetchMajorInfo()
    }
    
    func selectMajor(named majorName: String) {
        self.selectedMajor = majorName
        self.majorDetails = majorWithDetail[self.selectedMajor ?? ""] ?? []
    }
    
    func submitUserInfo() {
        guard let userInfo = CoreUsecase.fetchUserInfo() else {
            self.alertStatus = .coreDataFetchError
            return
        }
        self.saveUserInfoToDB(userInfo: userInfo)
        self.sendUserInfoToNetwork(userInfo: userInfo)
    }
    func clearAlert() {
        self.alertStatus = nil
    }
}

// MARK: Private functions
extension ChangeUserInfoVM {
    private func fetchMajorInfo() {
        networkUseCase.getMajors { [weak self] majorFetched in
            guard let majorFetched = majorFetched else {
                self?.alertStatus = .networkError
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
    
    private func getUserInfo() {
        guard let userInfo = CoreUsecase.fetchUserInfo() else { return }
        self.nickname = userInfo.nickName
        self.phonenum = userInfo.phoneNumber
        self.selectedMajor = userInfo.major
        self.selectedMajorDetail = userInfo.majorDetail
        self.schoolName = userInfo.schoolName
        self.graduationStatus = userInfo.graduationStatus
    }
    
    private func checkIfSubmitAvailable() -> Bool {
        guard [self.nickname, self.phonenum, self.selectedMajor, self.selectedMajorDetail, self.schoolName, self.graduationStatus].allSatisfy({ $0 != nil && $0 != "" }) else {
            self.alertStatus = .incompleteData
            return false
        }
        guard let selectedMajor = self.selectedMajor, let selectedMajorDetail = self.selectedMajorDetail else { return false }
        guard self.majorWithDetail[selectedMajor]?.contains(selectedMajorDetail) == true else {
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
        self.networkUseCase.putUserInfoUpdate(userInfo: userInfo) { status in
            DispatchQueue.main.async {
                switch status {
                case .SUCCESS:
                    self.alertStatus = .success // Error Handling 등 활용해서 보다 명확한 위치로 바꿀 수도 있을듯..
                default:
                    self.alertStatus = .networkError
                }
            }
        }
    }
}
