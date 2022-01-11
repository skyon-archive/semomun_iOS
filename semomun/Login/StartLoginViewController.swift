//
//  StartViewController.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/05.
//

import UIKit

class StartLoginViewController: UIViewController {
    static let identifier = "StartLoginViewController"
    
    @IBOutlet var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureLoginButton()
    }
    
    private func configureLoginButton() {
        self.loginButton.cornerRadius = 5
    }
    
    @IBAction func start(_ sender: Any) {
        let signUpInfo = UserInfo()
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: SurveyViewController.identifier) as? SurveyViewController else { return }
        nextVC.signUpInfo = signUpInfo
        
        self.title = ""
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func login(_ sender: Any) {
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: LoginViewController.identifier) else { return }
        
        self.title = ""
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}
