//
//  UnloginedProfileTableVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/24.
//

import UIKit

final class UnloginedProfileTableVC: UITableViewController {
    static let storyboardName = "Profile"
    static let identifier = "UnloginedProfileTableVC"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setHorizontalMargin(to: 109)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

extension UnloginedProfileTableVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section, indexPath.row) == (0, 0) {
            let storyboard = UIStoryboard(name: SettingVC.storyboardName, bundle: nil)
            let nextVC = storyboard.instantiateViewController(withIdentifier: SettingVC.identifier)
            self.navigationController?.pushViewController(nextVC, animated: true)
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
