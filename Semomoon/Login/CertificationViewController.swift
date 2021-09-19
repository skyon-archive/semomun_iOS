//
//  CheckPhoneViewController.swift
//  Semomoon
//
//  Created by qwer on 2021/09/19.
//

import UIKit

class CertificationViewController: UIViewController {

    @IBOutlet weak var warningOfName: UIView!
    @IBOutlet weak var warningOfName2: UILabel!
    @IBOutlet weak var warningOfPhone: UIView!
    @IBOutlet weak var warningOfPhone2: UILabel!
    @IBOutlet weak var warningOfCertification: UIView!
    @IBOutlet weak var warningOfCertification2: UILabel!
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var cirtification: UITextField!
    
    @IBOutlet weak var nextButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        nextButton.layer.cornerRadius = 35
        nextButton.clipsToBounds = true
    }
    
    @IBAction func dissmiss(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func nextVC(_ sender: Any) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "MainViewController") else { return }
        nextVC.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
        
        self.present(nextVC, animated: false, completion: nil) // present
    }
    
}
