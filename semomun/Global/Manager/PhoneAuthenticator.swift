//
//  PhoneAuthenticator.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/03/09.
//

import Foundation


struct PhoneAuthenticator {
    
    private var tempPhoneNumber = ""
    private var networkUsecase: PhonenumVerifiable
    
    func sendSMSCode(to phoneNum: String) {
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
    
    func verifySMSCode(_ code: String) {
        guard let tempPhoneNum = self.tempPhoneNum?.phoneNumberWithCountryCode else { return }
        self.networkUseCase.checkValidity(phoneNumber: tempPhoneNum, authNum: authNumber) {[weak self] confirmed in
            if confirmed {
                self?.phoneAuthStatus = .authComplete
                self?.phonenum = self?.tempPhoneNum
                self?.tempPhoneNum = nil
            } else {
                self?.phoneAuthStatus = .wrongAuthNumber
            }
        }
    }
}
