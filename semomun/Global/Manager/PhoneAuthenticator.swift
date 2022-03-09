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
    }
    
    private var tempPhoneNumber: String?
    private var networkUsecase: PhonenumVerifiable
    
    init(networkUsecase: PhonenumVerifiable) {
        self.networkUsecase = networkUsecase
    }
    
    /// - Parameter phoneNumber: 숫자로만 이루어진 전화번호 문자열
    func sendSMSCode(to phoneNumber: String, completion: @escaping (Result<String, CodeSendError>) -> Void) throws {
        self.networkUsecase.requestVertification(of: phoneNumber) { status in
            switch status {
            case .SUCCESS:
                self.tempPhoneNumber = phoneNumber
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
    
    func verifySMSCode(_ code: String, completion: @escaping (Result<Bool, CodeVerifyError>) -> Void) {
        guard let tempPhoneNumber = tempPhoneNumber else {
            completion(.failure(.codeNotSent))
            return
        }
        self.networkUsecase.checkValidity(phoneNumber: tempPhoneNumber, code: code) { isValid, networkStatus in
            switch networkStatus {
            case .SUCCESS:
                guard let isValid = isValid else {
                    assertionFailure()
                    return
                }
                self.tempPhoneNumber = nil
                completion(.success(isValid))
            default:
                completion(.failure(.noNetwork))
            }
            
        }
    }
}
