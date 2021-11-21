//
//  CheckPhoneViewController.swift
//  Semomoon
//
//  Created by qwer on 2021/09/19.
//

import UIKit

class CertificationViewController: UIViewController {
    static let identifier = "CertificationViewController"
    
    var Certificated: Bool = false
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "회원가입"
        let userIdentifier = KeychainItem.currentUserIdentifier
        print("userIdentifier: \(userIdentifier)")
    }
    
    @IBAction func dissmiss(_ sender: Any) {
//        self.dismiss(animated: false, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextVC(_ sender: Any) {
        if(Certificated){
            guard let nextVC = self.storyboard?.instantiateViewController(identifier: SurveyViewController.identifier) else { return }
            self.title = ""
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
        else{
            // need notification to try authenticating him/herself
        }
    }
    
}
