//
//  LoginStartVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/05.
//

import UIKit

class LoginStartVC: UIViewController {
    static let identifier = "LoginStartVC"
    static let storyboardName = "StartLogin"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func login(_ sender: Any) {
        guard let nextVC = UIStoryboard(name: LoginSelectVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: LoginSelectVC.identifier) as? LoginSelectVC else { return }
        nextVC.configurePopup(isNeeded: false)
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func signin(_ sender: Any) {
        guard let nextVC = UIStoryboard(name: LoginSignupVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: LoginSignupVC.identifier) as? LoginSignupVC else { return }
//        let signUpInfo = UserInfo()
//        let category = UserDefaultsManager.get(forKey: UserDefaultsManager.Keys.currentCategory) as? String ?? "수능모의고사"
//        signUpInfo.configureCategory(to: category)
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
