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
        nextVC.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
        
        self.present(nextVC, animated: false, completion: nil) // present
    }
    @IBAction func registerWithApple(_ sender: Any) {
    }
    @IBAction func login(_ sender: Any) {
    }
}
