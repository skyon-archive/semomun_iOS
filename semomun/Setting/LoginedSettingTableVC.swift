//
//  LoginedSettingTableVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/24.
//

import UIKit

final class LoginedSettingTableVC: UITableViewController, StoryboardController {
    static let identifier = "LoginedSettingTableVC"
    static var storyboardNames: [UIUserInterfaceIdiom : String] = [.pad: "Profile", .phone: "Profile_phone"]
    
    @IBOutlet weak var versionLabel: UILabel!
    private lazy var networkUsecase: LoginSignupPostable = {
        return NetworkUsecase(network: Network())
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.tableView.setHorizontalMargin(to: 16)
        } else {
            self.tableView.setHorizontalMargin(to: 109)
        }
        
        self.versionLabel.text =  Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "버전 정보 없음"
    }
    
    @IBAction func logout(_ sender: Any) {
        self.showLogoutedAlert()
    }
}

// MARK: - 로그아웃 로직
extension LoginedSettingTableVC {
    private func showLogoutedAlert() {
        self.showAlertWithCancelAndOK(title: "정말로 로그아웃 하시겠어요?", text: "필기와 이미지 데이터가 제거되며, 구매내역은 유지됩니다.") {
            self.logout()
        }
    }
    
    private func logout() {
        LogoutUsecase.logout()
        NotificationCenter.default.post(name: .logout, object: nil)
    }
    
    private func showResignAlert() {
        self.showAlertWithCancelAndOK(title: "정말로 탈퇴하시겠어요?", text: "세모페이와 구매 및 사용내역이 제거됩니다.") { [weak self] in
            self?.networkUsecase.resign(completion: { status in
                if status == .SUCCESS {
                    self?.logout()
                } else {
                    self?.showAlertWithOK(title: "탈퇴 실패", text: "네트워크 확인 후 다시 시도하시기 바랍니다.")
                }
            })
        }
    }
}

// MARK: - TableView 선택
extension LoginedSettingTableVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 1):
            self.showResignAlert()
        case (1, 1):
            self.showLongTextVC(title: "이용약관", txtResourceName: "termsAndConditions")
        case (1, 2):
            self.showLongTextVC(title: "개인정보 처리방침", txtResourceName: "personalInformationProcessingPolicy")
        case (1, 3):
            self.showLongTextVC(title: "마케팅 수신 동의", txtResourceName: "receiveMarketingInfo", marketingInfo: true)
        case (1, 4):
            self.showLongTextVC(title: "전자금융거래 이용약관", txtResourceName: "termsOfElectronicTransaction", marketingInfo: false)
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
