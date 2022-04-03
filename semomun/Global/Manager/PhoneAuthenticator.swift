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
    
    enum CodeResendError: Error {
        case noNetwork
        case smsSentTooMuch
    }
    
    private var tempPhoneNumberForResend: String?
    private let networkUsecase: PhonenumVerifiable
    
    init(networkUsecase: PhonenumVerifiable) {
        self.networkUsecase = networkUsecase
    }
    
    /// - Parameter phoneNumber: 숫자로만 이루어진 전화번호 문자열
    func sendSMSCode(to phoneNumber: String, completion: @escaping (Result<String, CodeSendError>) -> Void) {
        guard let phoneNumberWithCountryCode = phoneNumber.phoneNumberWithCountryCode else {
            completion(.failure(.invalidPhoneNumber))
            return
        }
        self.networkUsecase.requestVerification(of: phoneNumberWithCountryCode) { status in
            switch status {
            case .SUCCESS:
                self.tempPhoneNumberForResend = phoneNumberWithCountryCode
                completion(.success(phoneNumber))
            case .BADREQUEST:
                completion(.failure(.invalidPhoneNumber))
            case .TOOMANYREQUESTS:
                completion(.failure(.smsSentTooMuch))
            default:
                completion(.failure(.noNetwork))
            }
        }
    }
    
    func verifySMSCode(_ code: String, completion: @escaping (Result<String, CodeVerifyError>) -> Void) {
        guard let tempPhoneNumber = self.tempPhoneNumberForResend else {
            completion(.failure(.codeNotSent))
            return
        }
        self.networkUsecase.checkValidity(phoneNumber: tempPhoneNumber, code: code) { networkStatus, isValid in
            switch networkStatus {
            case .SUCCESS:
                guard let isValid = isValid,
                      let phoneNumber = tempPhoneNumber.phoneNumberWithNumbers else {
                    assertionFailure()
                    return
                }
                if isValid {
                    completion(.success(phoneNumber))
                    self.tempPhoneNumberForResend = nil
                } else {
                    completion(.failure(.wrongCode))
                }
            default:
                completion(.failure(.noNetwork))
            }
            
        }
    }
    
    func resendSMSCode(completion: @escaping (Result<String, CodeResendError>) -> Void) {
        guard let tempPhoneNumber = self.tempPhoneNumberForResend?.phoneNumberWithNumbers else {
            assertionFailure()
            return
        }
        self.sendSMSCode(to: tempPhoneNumber) { [weak self] result in
            switch result {
            case .success(let phoneNumber):
                completion(.success(phoneNumber))
            case .failure(let sendError):
                guard let resendError = self?.convertSendErrorToResendError(sendError) else {
                    assertionFailure()
                    return
                }
                completion(.failure(resendError))
            }
        }
    }
    
    private func convertSendErrorToResendError(_ error: CodeSendError) -> CodeResendError {
        switch error {
        case .invalidPhoneNumber:
            assertionFailure()
            return .noNetwork
        case .noNetwork:
            return .noNetwork
        case .smsSentTooMuch:
            return .smsSentTooMuch
        }
    }
}
