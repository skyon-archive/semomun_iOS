//
//  LoginedProfileTableVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/23.
//

import UIKit

final class LoginedProfileTableVC: UITableViewController, StoryboardController {
    static let identifier = "LoginedProfileTableVC"
    static var storyboardNames: [UIUserInterfaceIdiom : String] = [.pad: "Profile", .phone: "Profile_phone"]
    
    @IBOutlet weak var remainingPay: UILabel!
    
    private var networkUsecase: UserInfoFetchable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentInset = .init(top: 27, left: 0, bottom: 27, right: 0)
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.tableView.setHorizontalMargin(to: 16)
        } else {
            self.tableView.setHorizontalMargin(to: 109)
        }
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
        var nextVC: UIViewController?
        let storyboard = UIStoryboard(name: Self.storyboardName, bundle: nil)

        switch (indexPath.section, indexPath.row) {
        case (1, 0):
            nextVC = storyboard.instantiateViewController(withIdentifier: MyPurchasesVC.identifier)
        case (1, 1):
            nextVC = storyboard.instantiateViewController(withIdentifier: SemopayVC.identifier)
        case (2, 0):
            nextVC = UserNoticeVC()
        case (2, 1):
            if let url = URL(string: NetworkURL.customerService) {
                UIApplication.shared.open(url, options: [:])
            }
        case (2, 2):
            if let url = URL(string: NetworkURL.errorReportOfApp) {
                UIApplication.shared.open(url, options: [:])
            }
        case (2, 3):
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
