//
//  FindIDViewController.swift
//  Semomoon
//
//  Created by qwer on 2021/09/25.
//

import UIKit

class FindIDViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "아이디 찾기"
    }

    @IBAction func login(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func findPassword(_ sender: Any) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "FindPasswordViewController") else { return }
        self.title = ""
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}
