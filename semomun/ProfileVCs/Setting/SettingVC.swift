//
//  SettingVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/23.
//

import UIKit

class SettingVC: UIViewController {
    static let storyboardName = "Profile"
    static let identifier = "SettingVC"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "설정"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
