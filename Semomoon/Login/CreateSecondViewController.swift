//
//  CreateSecondViewController.swift
//  Semomoon
//
//  Created by qwer on 2021/09/22.
//

import UIKit

class CreateSecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "회원가입"
    }
    
    @IBAction func finish(_ sender: Any) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "MainViewController") else { return }
        nextVC.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
        
        self.present(nextVC, animated: false, completion: nil) // present
    }
    
}
