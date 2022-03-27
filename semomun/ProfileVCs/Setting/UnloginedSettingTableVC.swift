//
//  UnloginedSettingTableVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/24.
//

import UIKit

final class UnloginedSettingTableVC: UITableViewController {
    static let identifier = "UnloginedSettingTableVC"
    static let storyboardName = "Profile"
    static let storyboardName_phone = "Profile_phone"
    
    
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.tableView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        } else {
            self.tableView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 109, bottom: 0, trailing: 109)
        }
        
        self.versionLabel.text =  Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "버전 정보 없음"
    }
}

extension UnloginedSettingTableVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 1):
            self.showLongTextVC(title: "서비스이용약관", txtResourceName: "termsAndConditions")
        case (0, 2):
            self.showLongTextVC(title: "개인정보 처리방침", txtResourceName: "personalInformationProcessingPolicy")
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
