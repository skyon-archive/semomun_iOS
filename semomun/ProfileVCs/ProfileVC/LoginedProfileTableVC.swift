//
//  LoginedProfileTableVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/23.
//

import UIKit

final class LoginedProfileTableVC: UITableViewController {
    static let storyboardName = "Profile"
    static let identifier = "LoginedProfileTableVC"
    
    @IBOutlet weak var remainingPay: UILabel!
    
    private var networkUsecase: UserInfoFetchable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.setHorizontalMargin(to: 109)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updatePay()
    }
    
    func configureNetworkUsecase(_ networkUsecase: UserInfoFetchable) {
        self.networkUsecase = networkUsecase
    }

    @IBAction func chargeSemopay(_ sender: Any) {
        let storyboard = UIStoryboard(name: WaitingChargeVC.storyboardName, bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: WaitingChargeVC.identifier)
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}

extension LoginedProfileTableVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextVC: UIViewController
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        switch (indexPath.section, indexPath.row) {
        case (1, 0):
            nextVC = storyboard.instantiateViewController(withIdentifier: MyPurchasesVC.identifier)
        case (1, 1):
            nextVC = storyboard.instantiateViewController(withIdentifier: SemopayVC.identifier)
        case (2, 0):
            nextVC = storyboard.instantiateViewController(withIdentifier: SettingVC.identifier)
        default:
            return
        }
        self.navigationController?.pushViewController(nextVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension LoginedProfileTableVC {
    private func updatePay() {
        if let userInfo = CoreUsecase.fetchUserInfo() {
            guard NetworkStatusManager.isConnectedToInternet() else {
                self.remainingPay.text = "\(Int(userInfo.credit).withComma)원"
                return
            }
            
            self.networkUsecase?.getRemainingPay { status, credit in
                if let credit = credit {
                    self.remainingPay.text = "\(credit.withComma)원"
                    userInfo.updateCredit(credit)
                } else {
                    self.remainingPay.text = "?원"
                }
            }
        } else {
            self.remainingPay.text = "?원"
        }
        
    }
}
