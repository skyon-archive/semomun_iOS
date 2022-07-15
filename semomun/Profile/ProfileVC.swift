//
//  ProfileVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit

final class ProfileVC: UIViewController {
    private lazy var profileView: ProfileView = {
        let view = ProfileView(isLogined: true, delegate: self)
        return view
    }()
    private lazy var networkUsecase: LoginSignupPostable = {
        return NetworkUsecase(network: Network())
    }()
    override func loadView() {
        self.view = self.profileView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.profileView.updateUsername(to: "asd")
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
        
    }
    
    func showErrorReport() {
        
    }
    
    func resignAccount() {
        self.showAlertWithCancelAndOK(title: "정말로 탈퇴하시겠어요?", text: "세모페이와 구매 및 사용내역이 제거됩니다.") { [weak self] in
            self?.networkUsecase.resign(completion: { status in
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
