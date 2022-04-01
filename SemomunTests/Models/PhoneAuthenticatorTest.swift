//
//  PhoneAuthenticatorTest.swift
//  semomunTests
//
//  Created by SEONG YEOL YI on 2022/04/01.
//

import XCTest
@testable import semomun

final class PhoneAuthenticatorTest: XCTestCase {
    
    private var networkUsecase: MockPhoneNumVerifiable!
    private var phoneAuthenticator: PhoneAuthenticator!
    
    private let testPhoneNumber = "01012345678"
    private let testPhoneNumberWithCountryCode = "+82-10-1234-5678"
    
    override func setUp() {
        self.networkUsecase = MockPhoneNumVerifiable()
        self.phoneAuthenticator = PhoneAuthenticator(networkUsecase: self.networkUsecase)
    }
}

// sendSMSCode tests
extension PhoneAuthenticatorTest {
    func testNoNetworkSend() {
        self.networkUsecase.networkStatus = .FAIL
        self.phoneAuthenticator.sendSMSCode(to: testPhoneNumber) { result in
            XCTAssertEqual(result, .failure(.noNetwork))
        }
    }
    
    func testWrongFormatSend() {
        self.phoneAuthenticator.sendSMSCode(to: self.testPhoneNumberWithCountryCode) { result in
            XCTAssertEqual(result, .failure(.invalidPhoneNumber))
            XCTAssertNil(self.networkUsecase.inputParameter)
        }
    }
    
    func testToManyRequestOnSend() {
        self.networkUsecase.networkStatus = .TOOMANYREQUESTS
        self.phoneAuthenticator.sendSMSCode(to: self.testPhoneNumber) { result in
            XCTAssertEqual(result, .failure(.smsSentTooMuch))
        }
    }
    
    func testSuccessfulSend() {
        self.phoneAuthenticator.sendSMSCode(to: testPhoneNumber) { result in
            XCTAssertEqual(result, .success(self.testPhoneNumber))
            XCTAssertEqual(
                self.networkUsecase.inputParameter,
                self.testPhoneNumberWithCountryCode
            )
        }
    }
}

// resendSMSCode tests
extension PhoneAuthenticatorTest {
    func testCodeResendNoNetwork() {
        self.phoneAuthenticator.sendSMSCode(to: self.testPhoneNumber) { _ in
            self.networkUsecase.networkStatus = .FAIL
            self.phoneAuthenticator.resendSMSCode { result in
                XCTAssertEqual(result, .failure(.noNetwork))
            }
        }
    }
    
    func testToManyRequestOnResend() {
        self.phoneAuthenticator.sendSMSCode(to: self.testPhoneNumber) { _ in
            self.networkUsecase.networkStatus = .TOOMANYREQUESTS
            self.phoneAuthenticator.resendSMSCode { result in
                XCTAssertEqual(result, .failure(.smsSentTooMuch))
            }
        }
    }
    
    func testSuccessfulResend() {
        self.phoneAuthenticator.sendSMSCode(to: self.testPhoneNumber) { _ in
            self.phoneAuthenticator.resendSMSCode { result in
                XCTAssertEqual(result, .success(self.testPhoneNumber))
            }
        }
    }
}

// verifySMSCode tests
extension PhoneAuthenticatorTest {
    func testNoNetworkVerify() {
        self.phoneAuthenticator.sendSMSCode(to: self.testPhoneNumber) { _ in
            self.networkUsecase.networkStatus = .FAIL
            self.phoneAuthenticator.verifySMSCode(self.networkUsecase.testAuthCode) { result in
                XCTAssertEqual(result, .failure(.noNetwork))
            }
        }
    }
    
    func testCodeNotSent() {
        self.phoneAuthenticator.verifySMSCode(self.networkUsecase.testAuthCode) { result in
            XCTAssertEqual(result, .failure(.codeNotSent))
        }
    }
    
    func testWrongCodeVerify() {
        self.phoneAuthenticator.sendSMSCode(to: self.testPhoneNumber) { _ in
            self.phoneAuthenticator.verifySMSCode("000000") { result in
                XCTAssertEqual(result, .failure(.wrongCode))
            }
        }
    }
    
    func testVerifyAfterResend() {
        self.phoneAuthenticator.sendSMSCode(to: self.testPhoneNumber) { _ in
            self.phoneAuthenticator.resendSMSCode { _ in
                self.phoneAuthenticator.verifySMSCode(self.networkUsecase.testAuthCode) { result in
                    XCTAssertEqual(result, .success(self.testPhoneNumber))
                }
            }
        }
    }
}
