//
//  ChangeUserInfoVMTest.swift
//  semomunTests
//
//  Created by SEONG YEOL YI on 2022/04/06.
//

@testable import semomun
import XCTest

class ChangeUserInfoVMTest: XCTest {
    let networkUsecase = MockUserInfoVMNetwork()
    var vm: ChangeUserInfoVM!
    
    override func setUp() {
        self.vm = ChangeUserInfoVM(networkUseCase: self.networkUsecase)
    }
    
    func testInitialState() {
        XCTAssertEqual(vm.status, nil)
        XCTAssertEqual(vm.alert, nil)
        XCTAssertEqual(vm.userInfo, nil)
        XCTAssertEqual(vm.majors, [])
        XCTAssertEqual(vm.majorDetails, [])
        XCTAssertEqual(vm.configureUIForNicknamePhoneRequest, false)
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
        return false
    }
}
