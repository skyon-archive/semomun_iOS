//
//  BeforeLoginSettingTableVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/24.
//

import UIKit

class BeforeLoginSettingTableVC: UITableViewController {
    static let storyboardName = "Profile"
    static let identifier = "BeforeLoginSettingTableVC"
    
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 109, bottom: 0, trailing: 109)
        self.versionLabel.text =  Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "버전 정보 없음"
    }
}

extension BeforeLoginSettingTableVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 1):
            guard let filepath = Bundle.main.path(forResource: "termsAndConditions", ofType: "txt") else { return }
            do {
                let text = try String(contentsOfFile: filepath)
                self.popupTextViewController(title: "서비스이용약관", text: text)
            } catch {
                self.showAlertWithOK(title: "에러", text: "파일로딩에 실패하였습니다.")
            }
        case (0, 2):
            guard let filepath = Bundle.main.path(forResource: "personalInformationProcessingPolicy", ofType: "txt") else { return }
            do {
                let text = try String(contentsOfFile: filepath)
                self.popupTextViewController(title: "개인정보 처리방침", text: text)
            } catch {
                self.showAlertWithOK(title: "에러", text: "파일로딩에 실패하였습니다.")
            }
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
