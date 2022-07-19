//
//  ProfileViewDelegates.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/19.
//

import Foundation

enum ProfileVCLongTextType {
    case termsAndCondition
    case privacyPolicy
    case marketingAgree
    case termsOfTransaction
}

/// ProfileView의 로그인, 비로그인 공통 로직
protocol CommonProfileViewDelegate: AnyObject {
    func showNotice()
    func showServiceCenter()
    func showErrorReport()
    func resignAccount()
    func showLongText(type: ProfileVCLongTextType)
}

/// ProfileView의 로그인 상태 로직
protocol LoginProfileViewDelegate: CommonProfileViewDelegate {
    func showMyPurchases()
    func showChangeUserInfo()
    func logout()
}

/// ProfileView의 로그아웃 상태 로직
protocol LogoutProfileViewDelegate: CommonProfileViewDelegate {
    func login()
}
