//
//  LoginViewController.swift
//  Semomoon
//
//  Created by qwer on 2021/09/25.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "로그인"
    }

    @IBAction func findId(_ sender: Any) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "FindIDViewController") else { return }
        self.title = ""
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func findPassword(_ sender: Any) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "FindPasswordViewController") else { return }
        self.title = ""
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}
