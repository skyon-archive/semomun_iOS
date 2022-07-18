//
//  SignupVM.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/15.
//

import Foundation
import Combine

typealias LoginSignupVMNetworkUsecase = (MajorFetchable & UserInfoSendable & UsernameCheckable & PhonenumVerifiable)

final class SignupVM {
    @Published private(set) var signupStatus: LoginSignupStatus?
//    @Published private(set) var
}
