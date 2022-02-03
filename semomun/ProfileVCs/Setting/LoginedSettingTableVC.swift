//
//  LoginedSettingTableVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/24.
//

import UIKit

final class LoginedSettingTableVC: UITableViewController {
    static let storyboardName = "Profile"
    static let identifier = "LoginedSettingTableVC"
    
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.setHorizontalMargin(to: 109)
        self.versionLabel.text =  Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "버전 정보 없음"
    }
    
    @IBAction func logout(_ sender: Any) {
        CoreUsecase.deleteAllCoreData()
        self.deleteKeychain()
        self.deleteUserDefaults()
        self.showLogoutedAlert()
    }
}

// MARK: - 로그아웃 로직
extension LoginedSettingTableVC {
    private func deleteKeychain() {
        KeychainItem.deleteUserIdentifierFromKeychain()
        print("keychain delete complete")
    }
    
    private func deleteUserDefaults() {
        let dictionary = UserDefaults.standard.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            UserDefaults.standard.removeObject(forKey: key)
        }
        print("userDefaults delete complete")
    }
    
    private func showLogoutedAlert() {
        self.showAlertWithOK(title: "로그아웃 되었습니다", text: "") { [weak self] in
            let startVC = UIStoryboard(name: StartVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: StartVC.identifier)
            let navigationController = UINavigationController(rootViewController: startVC)
            navigationController.modalPresentationStyle = .fullScreen
            self?.present(navigationController, animated: true)
        }
    }
}

// MARK: - TableView 선택 
extension LoginedSettingTableVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 1):
            self.navigationController?.pushViewController(UserNoticeVC(), animated: true)
        case (1, 1):
            self.popupLongTextVC(title: "서비스이용약관", txtResourceName: "termsAndConditions")
        case (1, 2):
            self.popupLongTextVC(title: "개인정보 처리방침", txtResourceName: "personalInformationProcessingPolicy")
        case (1, 3):
            self.popupLongTextVC(title: "마케팅 정보 수신", txtResourceName: "receiveMarketingInfo", marketingInfo: true)
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
