//
//  SettingTableVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/24.
//

import UIKit

class SettingTableVC: UITableViewController {
    @IBOutlet weak var versionNum: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 109, bottom: 0, trailing: 109)
        self.versionNum.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "버전 정보 알 수 없음"
    }
    
    @IBAction func logout(_ sender: Any) {
        CoreUsecase.deleteAllCoreData()
        KeychainItem.deleteUserIdentifierFromKeychain()
        print("keychain delete complete")
        let dictionary = UserDefaults.standard.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            UserDefaults.standard.removeObject(forKey: key)
        }
        print("userDefaults delete complete")
        
        self.showAlertWithOK(title: "로그아웃 되었습니다", text: "") { [weak self] in
            let startVC = UIStoryboard(name: StartVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: StartVC.identifier)
            let navigationController = UINavigationController(rootViewController: startVC)
            navigationController.modalPresentationStyle = .fullScreen
            self?.present(navigationController, animated: true)
        }
    }
    
}

extension SettingTableVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 1):
            break
        case (1, 1):
            guard let filepath = Bundle.main.path(forResource: "termsAndConditions", ofType: "txt") else { return }
            do {
                let text = try String(contentsOfFile: filepath)
                self.popupTextViewController(title: "서비스이용약관", text: text)
            } catch {
                self.showAlertWithOK(title: "에러", text: "파일로딩에 실패하였습니다.")
            }
        case (1, 2):
            guard let filepath = Bundle.main.path(forResource: "personalInformationProcessingPolicy", ofType: "txt") else { return }
            do {
                let text = try String(contentsOfFile: filepath)
                self.popupTextViewController(title: "개인정보 처리방침", text: text)
            } catch {
                self.showAlertWithOK(title: "에러", text: "파일로딩에 실패하였습니다.")
            }
        case (1, 3):
            break
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SettingTableVC {
    private func popupTextViewController(title: String, text: String) {
        let storyboard = UIStoryboard(name: LongTextVC.storyboardName, bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: LongTextVC.identifier) as? LongTextVC else { return }
        vc.configureUI(title: title, text: text)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
