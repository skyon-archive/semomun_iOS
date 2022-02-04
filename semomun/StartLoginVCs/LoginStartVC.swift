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
    
    @IBOutlet var loginButtons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
    }
    
    @IBAction func login(_ sender: Any) {
        guard let nextVC = UIStoryboard(name: LoginSelectVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: LoginSelectVC.identifier) as? LoginSelectVC else { return }
        
        self.title = ""
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func signin(_ sender: Any) {
        guard let nextVC = UIStoryboard(name: LoginSignupVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: LoginSignupVC.identifier) as? LoginSignupVC else { return }
        let signUpInfo = UserInfo()
        let category = UserDefaultsManager.get(forKey: UserDefaultsManager.Keys.currentCategory) as? String ?? "수능모의고사"
        print(category)
        signUpInfo.configureCategory(to: category)
        nextVC.signUpInfo = signUpInfo
        
        self.title = ""
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension LoginStartVC {
    private func configureUI() {
        self.loginButtons.forEach { button in
            button.clipsToBounds = true
            button.layer.cornerRadius = 5
        }
        self.loginButtons[1].setTitle("회원가입", for: .normal)
        self.loginButtons[2].layer.borderWidth = 1
        self.loginButtons[2].layer.borderColor = UIColor(.mainColor)?.cgColor
    }
}
