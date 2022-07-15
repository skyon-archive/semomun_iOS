//
//  ProfileVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit

typealias ProfileNetworkUsecase = (LoginSignupPostable & UserInfoFetchable)

final class ProfileVC: UIViewController {
    private lazy var profileView: ProfileView = {
        let view = ProfileView(isLogined: true, delegate: self)
        return view
    }()
    private var networkUsecase: ProfileNetworkUsecase?
    override func loadView() {
        self.view = self.profileView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNetworkUsecase()
        self.configureObserver()
        NetworkStatusManager.state()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        if let nickname = CoreUsecase.fetchUserInfo()?.nickName {
            self.profileView.updateUsername(to: nickname)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

extension ProfileVC {
    private func configureNetworkUsecase() {
        self.networkUsecase = NetworkUsecase(network: Network())
    }
    
    private func configureObserver() {
        NotificationCenter.default.addObserver(forName: NetworkStatusManager.Notifications.connected, object: nil, queue: .current) { [weak self] _ in
            self?.updateRemainingPay()
        }
        NotificationCenter.default.addObserver(forName: NetworkStatusManager.Notifications.disconnected, object: nil, queue: .current) { [weak self] _ in
            self?.profileView.payStatusView.updateRemainingPay(to: nil)
        }
    }
    
    private func updateRemainingPay() {
        guard let userInfo = CoreUsecase.fetchUserInfo() else {
            assertionFailure()
            self.profileView.payStatusView.updateRemainingPay(to: nil)
            return
        }
        self.networkUsecase?.getRemainingPay { status, credit in
            guard status == .SUCCESS else {
                self.showAlertWithOK(title: "수신 불가", text: "최신버전으로 업데이트 후 다시 시도하시기 바랍니다.")
                return
            }
            if let credit = credit {
                self.profileView.payStatusView.updateRemainingPay(to: credit)
                userInfo.updateCredit(credit)
            } else {
                self.profileView.payStatusView.updateRemainingPay(to: nil)
            }
        }
    }
}

extension ProfileVC: ProfileViewDelegate {
    func showChangeUserInfo() {
        let storyboard = UIStoryboard(name: ChangeUserInfoVC.storyboardName, bundle: nil)
        guard let nextVC = storyboard.instantiateViewController(withIdentifier: ChangeUserInfoVC.identifier) as? ChangeUserInfoVC else { return }
        let viewModel = ChangeUserInfoVM(networkUseCase: NetworkUsecase(network: Network()))
        nextVC.configureVM(viewModel)
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func logout() {
        self.showAlertWithCancelAndOK(title: "정말로 로그아웃 하시겠어요?", text: "필기와 이미지 데이터는 앱 내에 유지됩니다.") {
            LogoutUsecase.logout()
        }
    }
    
    func showMyPurchases() {
        let storyboard = UIStoryboard(name: MyPurchasesVC.storyboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: MyPurchasesVC.identifier)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showNotice() {
        let vc = UserNoticeVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showServiceCenter() {
        if let url = URL(string: NetworkURL.customerService) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    func showErrorReport() {
        if let url = URL(string: NetworkURL.errorReportOfApp) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    func resignAccount() {
        self.showAlertWithCancelAndOK(title: "정말로 탈퇴하시겠어요?", text: "세모페이와 구매 및 사용내역이 제거됩니다.") { [weak self] in
            self?.networkUsecase?.resign(completion: { status in
                if status == .SUCCESS {let storyboard = UIStoryboard(name: ChangeUserInfoVC.storyboardName, bundle: nil)
                    guard let nextVC = storyboard.instantiateViewController(withIdentifier: ChangeUserInfoVC.identifier) as? ChangeUserInfoVC else { return }
                    let viewModel = ChangeUserInfoVM(networkUseCase: NetworkUsecase(network: Network()))
                    nextVC.configureVM(viewModel)
                    self?.navigationController?.pushViewController(nextVC, animated: true)
                    LogoutUsecase.logout()
                } else {
                    self?.showAlertWithOK(title: "탈퇴 실패", text: "네트워크 확인 후 다시 시도하시기 바랍니다.")
                }
            })
        }
    }
    
    func showTermsAndCondition() {
        self.showLongTextVC(title: "이용약관", txtResourceName: "termsAndConditions")
    }
    
    func showPrivacyPolicy() {
        self.showLongTextVC(title: "개인정보 처리방침", txtResourceName: "personalInformationProcessingPolicy")
    }
    
    func showMarketingAgree() {
        self.showLongTextVC(title: "마케팅 수신 동의", txtResourceName: "receiveMarketingInfo", marketingInfo: true)
    }
    
    func showTermsOfTransaction() {
        self.showLongTextVC(title: "전자금융거래 이용약관", txtResourceName: "termsOfElectronicTransaction", marketingInfo: false)
    }
}
