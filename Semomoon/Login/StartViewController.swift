//
//  StartViewController.swift
//  StartViewController
//
//  Created by qwer on 2021/09/19.
//

import UIKit

class StartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func register(_ sender: Any) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "CertificationViewController") else { return }
        self.title = ""
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func registerWithApple(_ sender: Any) {
    }
    @IBAction func login(_ sender: Any) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "LoginViewController") else { return }
        self.title = ""
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}
