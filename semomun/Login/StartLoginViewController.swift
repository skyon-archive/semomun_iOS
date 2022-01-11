//
//  StartViewController.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/05.
//

import UIKit

class StartLoginViewController: UIViewController {
    static let identifier = "StartLoginViewController"
    
    @IBOutlet var loginButtons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
    }
    
    @IBAction func login(_ sender: Any) {
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: LoginViewController.identifier) else { return }
        
        self.title = ""
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func signin(_ sender: Any) {
        let signUpInfo = UserInfo()
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: SurveyViewController.identifier) as? SurveyViewController else { return }
        nextVC.signUpInfo = signUpInfo
        
        self.title = ""
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension StartLoginViewController {
    private func configureUI() {
        self.loginButtons.forEach { button in
            button.clipsToBounds = true
            button.layer.cornerRadius = 5
        }
        self.loginButtons[2].layer.borderWidth = 1
        self.loginButtons[2].layer.borderColor = UIColor(named: SemomunColor.mainColor)?.cgColor
    }
}
