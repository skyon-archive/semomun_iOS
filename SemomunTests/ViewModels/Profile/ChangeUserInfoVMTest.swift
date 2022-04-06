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
}

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

// nil과의 비교만 필요해 임시 구현
extension UserInfo: Equatable {
    public static func == (lhs: UserInfo, rhs: UserInfo) -> Bool {
<<<<<<< HEAD
        XCTFail()
        return false
=======
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
>>>>>>> ffaee0db ([Feat] SyncUsecase에 네트워크를 주입하도록해 테스트 가능하도록 수정)
    }
}
