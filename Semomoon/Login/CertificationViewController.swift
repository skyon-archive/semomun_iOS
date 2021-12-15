//
//  CheckPhoneViewController.swift
//  Semomoon
//
//  Created by qwer on 2021/09/19.
//

import UIKit

class CertificationViewController: UIViewController {
    static let identifier = "CertificationViewController"

    @IBOutlet weak var warningOfName: UIView!
    @IBOutlet weak var warningOfName2: UILabel!
    @IBOutlet weak var warningOfPhone: UIView!
    @IBOutlet weak var warningOfPhone2: UILabel!
    @IBOutlet weak var warningOfCertification: UIView!
    @IBOutlet weak var warningOfCertification2: UILabel!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var certification: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    var Certificated: Bool = false
    var signUpInfo: SignUpInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        self.signUpInfo = SignUpInfo()
        self.configureNextButton()
        self.configureWarningUI()
        self.configureDelegate()
        self.configureTextFieldAction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "회원가입"
    }
    
    @IBAction func nextVC(_ sender: Any) {
        Certificated = true
        if(Certificated){
            guard let name = self.name.text,
                  let phoneNumber = self.phone.text else { return }
            self.signUpInfo.configureFirst(name: name, phoneNumber: phoneNumber)
            guard let nextVC = self.storyboard?.instantiateViewController(identifier: SurveyViewController.identifier) as? SurveyViewController else { return }
            self.title = ""
            nextVC.signUpInfo = self.signUpInfo
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
        else{
            // need notification to try authenticating him/herself
        }
    }
    
}

extension CertificationViewController: UITextFieldDelegate {
    func configureNextButton() {
        self.nextButton.layer.cornerRadius = 35
        self.nextButton.clipsToBounds = true
    }
    
    func configureWarningUI() {
        self.warningOfName.isHidden = true
        self.warningOfName2.isHidden = true
        self.warningOfPhone.isHidden = true
        self.warningOfPhone2.isHidden = true
        self.warningOfCertification.isHidden = true
        self.warningOfCertification2.isHidden = true
    }
    
    func configureDelegate() {
        self.name.delegate = self
        self.phone.delegate = self
        self.certification.delegate = self
    }
    
    func configureTextFieldAction() {
        self.name.addTarget(self, action: #selector(self.nameChanged), for: .editingChanged)
        self.phone.addTarget(self, action: #selector(self.phoneChanged), for: .editingChanged)
        self.certification.addTarget(self, action: #selector(self.certificationChanged), for: .editingChanged)
    }
    
    @objc func nameChanged() {
        print(name.text)
    }
    
    @objc func phoneChanged() {
        print(phone.text)
    }
    
    @objc func certificationChanged() {
        print(certification.text)
    }
}
