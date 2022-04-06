//
//  UnloginedProfileTableVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/24.
//

import UIKit

final class UnloginedProfileTableVC: UITableViewController, StoryboardController {
    static let identifier = "UnloginedProfileTableVC"
    static var storyboardNames: [UIUserInterfaceIdiom : String] = [.pad: "Profile", .phone: "Profile_phone"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.tableView.setHorizontalMargin(to: 16)
        } else {
            self.tableView.setHorizontalMargin(to: 109)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

extension UnloginedProfileTableVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var nextVC: UIViewController?
        let storyboard = UIStoryboard(name: Self.storyboardName, bundle: nil)

        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            nextVC = UserNoticeVC()
        case (0, 1):
            if let url = URL(string: NetworkURL.customerService) {
                UIApplication.shared.open(url, options: [:])
            }
        case (0, 2):
            if let url = URL(string: NetworkURL.errorReport) {
                UIApplication.shared.open(url, options: [:])
            }
        case (0, 3):
            nextVC = storyboard.instantiateViewController(withIdentifier: SettingVC.identifier)
        default:
            return
        }
        if let nextVC = nextVC {
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
