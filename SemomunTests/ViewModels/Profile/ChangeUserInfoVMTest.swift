//
//  ChangeUserInfoVMTest.swift
//  semomunTests
//
//  Created by SEONG YEOL YI on 2022/04/06.
//

@testable import semomun
import XCTest

class ChangeUserInfoVMTest: XCTestCase {
    let networkUsecase = MockUserInfoVMNetwork()
    var vm: ChangeUserInfoVM!
    
    override func setUp() {
        self.vm = ChangeUserInfoVM(networkUseCase: self.networkUsecase)
    }
    
    func testInitialState() {
        XCTAssertEqual(self.vm.status, nil)
        XCTAssertEqual(self.vm.alert, nil)
        XCTAssertEqual(self.vm.userInfo, nil)
        XCTAssertEqual(self.vm.majors, [])
        XCTAssertEqual(self.vm.majorDetails, [])
        XCTAssertEqual(self.vm.configureUIForNicknamePhoneRequest, false)
    }
    
    func testFetchData() {
        self.vm.fetchData()
        
        XCTAssertEqual(self.vm.status, nil)
        XCTAssertEqual(self.vm.alert, nil)
        XCTAssertEqual(vm.userInfo, self.networkUsecase.userInfo)
        XCTAssertEqual(self.vm.majors, self.networkUsecase.majors.map(\.name))
        XCTAssertEqual(self.vm.majorDetails, [])
        XCTAssertEqual(self.vm.configureUIForNicknamePhoneRequest, false)
    }
    
    func testNoNetworkFetchData() {
        self.networkUsecase.reachability = false
        self.vm.fetchData()
        
        XCTAssertEqual(self.vm.alert, .networkErrorWithPop)
    }
    
    func testCheckUsernameFormat() {
        // 길이
        self.vm.checkUsernameFormat("123")
        XCTAssertEqual(self.vm.status, .usernameGoodFormat)
        self.vm.checkUsernameFormat("12345678912345678912")
        XCTAssertEqual(self.vm.status, .usernameGoodFormat)
        self.vm.checkUsernameFormat("123456789123456789123")
        XCTAssertEqual(self.vm.status, .usernameWrongFormat)
        
        // 허용 문자
        self.vm.checkUsernameFormat("123;123")
        XCTAssertEqual(self.vm.status, .usernameWrongFormat)
        self.vm.checkUsernameFormat("__________")
        XCTAssertEqual(self.vm.status, .usernameGoodFormat)
        self.vm.checkUsernameFormat("_+=")
        XCTAssertEqual(self.vm.status, .usernameWrongFormat)
    }
    
    func testCheckPhoneNumberFormat() {
        self.vm.checkPhoneNumberFormat("010-1234")
        XCTAssertEqual(self.vm.status, .phoneNumberWrongFormat)
        self.vm.checkPhoneNumberFormat("010123456789")
        XCTAssertEqual(self.vm.status, .phoneNumberWrongFormat)
        self.vm.checkPhoneNumberFormat("010123456")
        XCTAssertEqual(self.vm.status, .phoneNumberGoodFormat)
    }
    
    func testChangeUsername() {
        self.vm.fetchData()
        
        // 사용중인 이름
        self.vm.changeUsername(self.networkUsecase.usedName.randomElement()!)
        XCTAssertEqual(self.vm.status, .usernameAlreadyUsed)
        XCTAssertEqual(self.vm.userInfo?.username, self.networkUsecase.userInfo.username)
        
        // 사용할 수 없는 이름
        self.vm.changeUsername("*")
        XCTAssertEqual(self.vm.status, .usernameWrongFormat)
        XCTAssertEqual(self.vm.userInfo?.username, self.networkUsecase.userInfo.username)
        
        // 기존 이름
        self.vm.changeUsername(self.networkUsecase.userInfo.username!)
        XCTAssertEqual(self.vm.status, .usernameAvailable)
        XCTAssertEqual(self.vm.userInfo?.username, self.networkUsecase.userInfo.username)
        
        // 사용할 수 있는 이름
        let newUsername = "___________________a"
        self.vm.changeUsername(newUsername)
        XCTAssertEqual(self.vm.status, .usernameAvailable)
        XCTAssertEqual(self.vm.userInfo?.username, newUsername)
        
        // 네트워크
        self.networkUsecase.reachability = false
        self.vm.changeUsername("abc123")
        XCTAssertEqual(self.vm.alert, .networkErrorWithoutPop)
        XCTAssertEqual(self.vm.userInfo?.username, newUsername)
    }
    
    func testSelectMajor() {
        self.vm.fetchData()
        self.vm.selectMajor(at: 1)
        
        let major = self.networkUsecase.majors[1]
        XCTAssertEqual(self.vm.majorDetails, major.details)
        XCTAssertEqual(self.vm.userInfo?.major, major.name)
        XCTAssertEqual(self.vm.userInfo?.majorDetail, nil)
    }
    
    func testSelectMajorDetail() {
        self.vm.fetchData()
        self.vm.selectMajor(at: 2)
        self.vm.selectMajorDetail(at: 1)
        
        let major = self.networkUsecase.majors[2]
        XCTAssertEqual(self.vm.userInfo?.majorDetail, major.details[1])
    }
    
    func testSubmitFlow() {
        self.vm.fetchData()
        
        self.vm.changeUsername("abc123")
        self.vm.selectMajor(at: 1)
        self.vm.selectMajorDetail(at: 2)
        self.vm.requestPhoneAuth(withPhoneNumber: "01012345678")
        self.vm.confirmAuthNumber(with: self.networkUsecase.validAuthCode)
        
        XCTAssertEqual(self.vm.userInfo?.username, "abc123")
        XCTAssertEqual(self.vm.userInfo?.phoneNumber, "01012345678")
        XCTAssertEqual(self.vm.userInfo?.major, self.networkUsecase.majors[1].name)
        XCTAssertEqual(self.vm.userInfo?.majorDetail, self.networkUsecase.majors[1].details[2])
    }
}

// MARK: - Supporting

extension LoginSignupAlert: Equatable {
    public static func == (lhs: LoginSignupAlert, rhs: LoginSignupAlert) -> Bool {
        switch (lhs, rhs) {
        case let (.alertWithPop(t1, d1), .alertWithPop(t2, d2)):
            return t1==t2 && d1==d2
        case let (.alertWithoutPop(t1, d1), .alertWithoutPop(t2, d2)):
            return t1==t2 && d1==d2
        default:
            return false
        }
    }
}

extension UserInfo: Equatable {
    public static func == (lhs: UserInfo, rhs: UserInfo) -> Bool {
        return lhs.uid == rhs.uid &&
        lhs.name == rhs.name &&
        lhs.username == rhs.username &&
        lhs.email == rhs.email &&
        lhs.gender == rhs.gender &&
        lhs.birth == rhs.birth &&
        lhs.major == rhs.major &&
        lhs.majorDetail == rhs.majorDetail &&
        lhs.school == rhs.school &&
        lhs.graduationStatus == rhs.graduationStatus &&
        lhs.credit == rhs.credit &&
        lhs.createdDate == rhs.createdDate &&
        lhs.updatedDate == rhs.updatedDate
    }
}
