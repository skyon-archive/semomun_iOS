//
//  SignupUsecase.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/18.
//

import Foundation
import Combine

final class SignupUsecase {
    enum SignupError {
        case networkError
        case localError
        case userAlreadyExist
    }
    
    @Published private(set) var signupCompleted: Bool = false
    @Published private(set) var signupError: SignupError?
    let userInfo: SignupUserInfo
    let networkUsecase: NetworkUsecase
    
    init(userInfo: SignupUserInfo, networkUsecase: NetworkUsecase) {
        self.userInfo = userInfo
        self.networkUsecase = networkUsecase
    }
    
    func signup(userIDToken: NetworkURL.UserIDToken) {
        self.networkUsecase.postSignup(userIDToken: userIDToken, userInfo: userInfo) { [weak self] status, userAlreadyExist in
            guard userAlreadyExist == false else {
                self?.signupError = .userAlreadyExist
                return
            }
            
            guard status == .SUCCESS else {
                self?.signupError = .networkError
                return
            }
            
            guard let networkUsecase = self?.networkUsecase else { return }
            LoginSignupUsecase(networkUsecase: networkUsecase).setLocalDataAfterSignup(token: userIDToken.userID) { [weak self] success in
                guard success == true else {
                    self?.signupError = .localError
                    return
                }
                self?.signupCompleted = true
            }
        }
    }
}
