//
//  BeforeLoginProfileTableVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/24.
//

import UIKit

final class BeforeLoginProfileTableVC: UITableViewController {
    static let storyboardName = "Profile"
    static let identifier = "BeforeLoginProfileTableVC"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 109, bottom: 0, trailing: 109)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

extension BeforeLoginProfileTableVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0, indexPath.row == 0 {
            let storyboard = UIStoryboard(name: Self.storyboardName, bundle: nil)
            let nextVC = storyboard.instantiateViewController(withIdentifier: SettingVC.identifier)
            self.navigationController?.pushViewController(nextVC, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
