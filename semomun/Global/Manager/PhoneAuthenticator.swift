//
//  PhoneAuthenticator.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/03/09.
//

import Foundation

class PhoneAuthenticator {
    
    enum CodeSendError: Error {
        case noNetwork
        case invalidPhoneNumber
        case smsSentTooMuch
    }
    
    enum CodeVerifyError: Error {
        case noNetwork
        case codeNotSent
        case wrongCode
    }
    
    private var tempPhoneNumber: String?
    private let networkUsecase: PhonenumVerifiable
    
    /// 현재 인증중인 전화번호(숫자로만 이루어진 문자열)
    var phoneNumberAuthenticating: String? {
        return self.tempPhoneNumber?.phoneNumberWithNumbers
    }
    
    init(networkUsecase: PhonenumVerifiable) {
        self.networkUsecase = networkUsecase
    }
    
    /// - Parameter phoneNumber: 숫자로만 이루어진 전화번호 문자열
    func sendSMSCode(to phoneNumber: String, completion: @escaping (Result<String, CodeSendError>) -> Void) {
        guard let phoneNumberWithCountryCode = phoneNumber.phoneNumberWithCountryCode else {
            completion(.failure(.invalidPhoneNumber))
            return
        }
        self.networkUsecase.requestVertification(of: phoneNumberWithCountryCode) { status in
            switch status {
            case .SUCCESS:
                self.tempPhoneNumber = phoneNumberWithCountryCode
                completion(.success(phoneNumber))
            case .BADREQUEST:
                completion(.failure(.invalidPhoneNumber))
            case .TOOMANYREQUESTS:
                completion(.failure(.smsSentTooMuch))
            default:
                assertionFailure()
                completion(.failure(.noNetwork))
            }
        }
    }
    
    /// - Parameters:
    ///   - completion: 올바른 code가 전달되면
    func verifySMSCode(_ code: String, completion: @escaping (Result<String, CodeVerifyError>) -> Void) {
        guard let tempPhoneNumber = tempPhoneNumber else {
            completion(.failure(.codeNotSent))
            return
        }
        self.networkUsecase.checkValidity(phoneNumber: tempPhoneNumber, code: code) { networkStatus, isValid in
            switch networkStatus {
            case .SUCCESS:
                guard let isValid = isValid else {
                    assertionFailure()
                    return
                }
                if isValid {
                    completion(.success(tempPhoneNumber))
                    self.tempPhoneNumber = nil
                } else {
                    completion(.failure(.wrongCode))
                }
            default:
                completion(.failure(.noNetwork))
            }
            
        }
    }
}
