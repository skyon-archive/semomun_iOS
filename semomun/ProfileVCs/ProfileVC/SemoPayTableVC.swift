//
//  SemoPayTableVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/23.
//

import UIKit

final class SemoPayTableVC: UITableViewController {
    static let storyboardName = "Profile"

    @IBOutlet weak var availableSemoPay: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 109, bottom: 0, trailing: 109)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.configureAvailableSemopay()
    }

    @IBAction func chargeSemopay(_ sender: Any) {
        let storyboard = UIStoryboard(name: WaitingChargeVC.storyboardName, bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: WaitingChargeVC.identifier)
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}

extension SemoPayTableVC {
    private func configureAvailableSemopay() {
        self.availableSemoPay.text = "13800원"
    }
}

extension SemoPayTableVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextVC: UIViewController
        let storyboard = UIStoryboard(name: Self.storyboardName, bundle: nil)
        switch (indexPath.section, indexPath.row) {
        case (1, 0):
            nextVC = storyboard.instantiateViewController(withIdentifier: SemopayVC.identifier)
        case (1, 1):
            nextVC = storyboard.instantiateViewController(withIdentifier: MyPurchasesVC.identifier)
        case (2, 0):
            nextVC = storyboard.instantiateViewController(withIdentifier: SettingVC.identifier)
        default:
            return
        }
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}
