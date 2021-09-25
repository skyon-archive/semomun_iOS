//
//  FindPasswordViewController.swift
//  Semomoon
//
//  Created by qwer on 2021/09/25.
//

import UIKit

class FindPasswordViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "비밀번호 찾기"
    }
    
    @IBAction func login(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func findID(_ sender: Any) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "FindIDViewController") else { return }
        self.title = ""
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
}
