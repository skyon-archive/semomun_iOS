//
//  SettingViewController.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2021/12/28.
//

import UIKit

class SettingViewController: UIViewController {
    static let identifier = "SettingViewController"
    
    @IBOutlet weak var versionNum: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "설정"
        self.versionNum.text =  Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
    }
    
    @IBAction func userLogout(_ sender: Any) {
    }
    
    @IBAction func userWithdrawal(_ sender: Any) {
    }
    
    @IBAction func openCustomerService(_ sender: Any) {
    }
    
    @IBAction func openTermsAndCondition(_ sender: Any) {
    }
    
    @IBAction func openPersonalInformationPolicy(_ sender: Any) {
    }
}
