//
//  SignupUsecase.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/18.
//

import Foundation
import Combine

final class SignupUsecase {
    @Published private(set) var signupCompleted: Bool = false
    let userInfo: SignupUserInfo
    let networkUsecase: NetworkUsecase
    
    init(userInfo: SignupUserInfo, networkUsecase: NetworkUsecase) {
        self.userInfo = userInfo
        self.networkUsecase = networkUsecase
    }
    
    func signup(userIDToken: NetworkURL.UserIDToken) {
//        self.networkUsecase.postLogin(userToken: userIDToken) { [weak self] result in
//            self?.handleLoginNetworkResult(token: userIDToken.userID, networkResult: result)
//        }
        
        
        dump(userIDToken)
        
        self.signupCompleted = true
    }
}
