//
//  PersonalSettingViewController.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/18.
//

import UIKit

class PersonalSettingViewController: UIViewController {
    static let identifier = "PersonalSettingViewController"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "설정"
        self.loadUserInfo()
    }
    
    @IBAction func showSettingNameVC(_ sender: Any) {
        self.showSettingNames()
    }
}

extension PersonalSettingViewController {
    private func loadUserInfo() {
        guard let userInfo = CoreUsecase.fetchUserInfo() else {
            print("no userInfo error")
            return
        }
        print(userInfo)
    }
    private func showSettingNames() {
        guard let settingNameVC = self.storyboard?.instantiateViewController(withIdentifier: PersonalSettingNameViewController.identifier) as? PersonalSettingNameViewController else { return }
        
        self.present(settingNameVC, animated: true, completion: nil)
    }
}
