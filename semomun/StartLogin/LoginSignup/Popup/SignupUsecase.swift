//
//  SignupUsecase.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/18.
//

import Foundation

final class SignupUsecase {
    let userInfo: SignupUserInfo
    let networkUsecase: NetworkUsecase
    
    init(userInfo: SignupUserInfo, networkUsecase: NetworkUsecase) {
        self.userInfo = userInfo
        self.networkUsecase = networkUsecase
    }
}
