//
//  ProfileVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit

typealias ProfileNetworkUsecase = (LoginSignupPostable & UserInfoFetchable)

final class ProfileVC: UIViewController {
    private lazy var loginProfileView: LoginProfileView = {
        let view = LoginProfileView(delegate: self)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var logoutProfileView: LogoutProfileView = {
        let view = LogoutProfileView(delegate: self)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var networkUsecase: ProfileNetworkUsecase? = NetworkUsecase(network: Network())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.getSemomunColor(.background)
        if UserDefaultsManager.isLogined == true {
            self.showLoginProfileView()
        } else {
            self.showLogoutProfileView()
        }
        self.configureObserver()
        NetworkStatusManager.state()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaultsManager.isLogined == true {
            self.updateNickname()
            self.updateRemainingPay()
        }
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

extension ProfileVC {
    private func configureObserver() {
        NotificationCenter.default.addObserver(forName: NetworkStatusManager.Notifications.connected, object: nil, queue: .current) { [weak self] _ in
            guard UserDefaultsManager.isLogined == true else { return }
            self?.updateRemainingPay()
        }
        NotificationCenter.default.addObserver(forName: NetworkStatusManager.Notifications.disconnected, object: nil, queue: .current) { [weak self] _ in
            guard UserDefaultsManager.isLogined == true else { return }
            self?.loginProfileView.payStatusView.updateRemainingPay(to: nil)
        }
        NotificationCenter.default.addObserver(forName: .logined, object: nil, queue: .current) { [weak self] _ in
            self?.showLoginProfileView()
        }
        NotificationCenter.default.addObserver(forName: .logout, object: nil, queue: .current) { [weak self] _ in
            self?.showLogoutProfileView()
        }
    }
    
    private func updateNickname() {
        if let nickname = CoreUsecase.fetchUserInfo()?.nickName {
            self.loginProfileView.updateUsername(to: nickname)
        }
    }
    
    private func updateRemainingPay() {
        guard let userInfo = CoreUsecase.fetchUserInfo() else {
            assertionFailure()
            self.loginProfileView.payStatusView.updateRemainingPay(to: nil)
            return
        }
        self.networkUsecase?.getRemainingPay { status, credit in
            guard status == .SUCCESS else {
                if status == .DECODEERROR {
                    self.showAlertWithOK(title: "수신 불가", text: "최신버전으로 업데이트 후 다시 시도하시기 바랍니다.")
                }
                return
            }
            if let credit = credit {
                self.loginProfileView.payStatusView.updateRemainingPay(to: credit)
                userInfo.updateCredit(credit)
            } else {
                self.loginProfileView.payStatusView.updateRemainingPay(to: nil)
            }
        }
    }
    
    private func showLoginProfileView() {
        self.logoutProfileView.removeFromSuperview()
        self.view.addSubview(self.loginProfileView)
        NSLayoutConstraint.activate([
            self.loginProfileView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.loginProfileView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.loginProfileView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.loginProfileView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
        ])
        self.updateNickname()
        self.updateRemainingPay()
    }
    
    private func showLogoutProfileView() {
        self.loginProfileView.removeFromSuperview()
        self.view.addSubview(self.logoutProfileView)
        NSLayoutConstraint.activate([
            self.logoutProfileView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.logoutProfileView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.logoutProfileView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.logoutProfileView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}

extension ProfileVC: LoginProfileViewDelegate & LogoutProfileViewDelegate {
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
        let networkUsecase = NetworkUsecase(network: Network())
        let viewModel = PayHistoryVM(onlyPurchaseHistory: true, networkUsecase: networkUsecase)
        let vc = MyPurchasesVC(viewModel: viewModel)
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
                if status == .SUCCESS {
                    LogoutUsecase.logout()
                } else {
                    self?.showAlertWithOK(title: "탈퇴 실패", text: "네트워크 확인 후 다시 시도하시기 바랍니다.")
                }
            })
        }
    }
    
    func showLongText(type: ProfileVCLongTextType) {
        switch type {
        case .termsAndCondition:
            self.showLongTextVC(title: "이용약관", txtResourceName: "termsAndConditions")
        case .privacyPolicy:
            self.showLongTextVC(title: "개인정보 처리방침", txtResourceName: "personalInformationProcessingPolicy")
        case .marketingAgree:
            self.showLongTextVC(title: "마케팅 수신 동의", txtResourceName: "receiveMarketingInfo", marketingInfo: true)
        case .termsOfTransaction:
            self.showLongTextVC(title: "전자금융거래 이용약관", txtResourceName: "termsOfElectronicTransaction", marketingInfo: false)
        }
    }
    
    func login() {
        NotificationCenter.default.post(name: .showLoginStartVC, object: nil)
    }
}
