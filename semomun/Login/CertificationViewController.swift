//
//  CertificationViewController.swift
//  semomun
//
//  Created by Kang Minsang on 2021/09/19.
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
    
    private var signUpInfo: SignUpInfo?
    private var usecase: CertificationUseCase?
    private var states: [Bool] = [false, false, false]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        self.configureProperty()
        self.configureNextButton()
        self.configureWarningUI()
        self.configureDelegate()
        self.configureTextFieldAction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "회원가입"
    }
    
    @IBAction func sendPhone(_ sender: Any) {
        self.dismissKeyboard()
        self.usecase?.checkPhone(with: self.phone.text, completion: { [weak self] valid in
            if let valid = valid {
                if valid {
                    self?.states[1] = true
                    self?.showAlertWithOK(title: "전송 완료", text: "인증번호를 확인해주시기 바랍니다.")
                } else {
                    self?.showAlertWithOK(title: "전송 실패", text: "다시 시도하시기 바랍니다.")
                }
            } else {
                self?.showAlertWithOK(title: "네트워크 오류", text: "다시 시도하시기 바랍니다.")
            }
        })
    }
    @IBAction func sendCertification(_ sender: Any) {
        self.dismissKeyboard()
        self.usecase?.checkCertification(with: self.phone.text, completion: { [weak self] valid in
            if let valid = valid {
                if valid {
                    self?.states[2] = true
                    self?.showAlertWithOK(title: "인증 완료", text: "인증이 완료되었습니다.")
                } else {
                    self?.showAlertWithOK(title: "인증 실패", text: "다시 시도하시기 바랍니다.")
                }
            } else {
                self?.showAlertWithOK(title: "네트워크 오류", text: "다시 시도하시기 바랍니다.")
            }
        })
    }
    
    @IBAction func nextVC(_ sender: Any) {
        guard let usecase = self.usecase else { return }
        if usecase.isValidForSignUp(states: self.states) {
            self.configureSignUpInfo()
            self.nextVC()
        }
        else {
            self.showAlertWithOK(title: "정보가 부족합니다", text: "정보를 모두 기입해주시기 바랍니다.")
        }
    }
    
}

extension CertificationViewController: UITextFieldDelegate {
    func configureProperty() {
        self.signUpInfo = SignUpInfo()
        self.usecase = CertificationUseCase(delegate: self)
    }
    
    func configureNextButton() {
        self.nextButton.layer.cornerRadius = 35
        self.nextButton.clipsToBounds = true
    }
    
    func configureWarningUI() {
        self.validNameUI()
        self.validPhoneUI()
        self.validCertificationUI()
    }
    
    func validNameUI() {
        self.warningOfName.isHidden = true
        self.warningOfName2.isHidden = true
    }
    
    func validPhoneUI() {
        self.warningOfPhone.isHidden = true
        self.warningOfPhone2.isHidden = true
    }
    
    func validCertificationUI() {
        self.warningOfCertification.isHidden = true
        self.warningOfCertification2.isHidden = true
    }
    
    func invalidNameUI() {
        self.warningOfName.isHidden = false
        self.warningOfName2.isHidden = false
    }
    
    func invalidPhoneUI() {
        self.warningOfPhone.isHidden = false
        self.warningOfPhone2.isHidden = false
    }
    
    func invalidCertificationUI() {
        self.warningOfCertification.isHidden = false
        self.warningOfCertification2.isHidden = false
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
        self.usecase?.checkName(with: name.text)
    }
    
    @objc func phoneChanged() {
        self.usecase?.checkPhone(with: phone.text)
    }
    
    @objc func certificationChanged() {
        self.usecase?.checkCertification(with: certification.text)
    }
    
    func configureSignUpInfo() {
        guard let name = self.name.text,
              let phoneNumber = self.phone.text else { return }
        
        self.signUpInfo?.configureName(to: name)
        self.signUpInfo?.configurePhoneNumber(to: phoneNumber)
        self.signUpInfo?.configureToken(to: KeychainItem.currentUserIdentifier)
    }
    
    func nextVC() {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: SurveyViewController.identifier) as? SurveyViewController else { return }
        nextVC.signUpInfo = self.signUpInfo
        
        self.title = ""
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}

extension CertificationViewController: Certificateable {
    func nameResult(result: CertificationUseCase.Results) {
        switch result {
        case .valid:
            self.states[0] = true
            self.validNameUI()
        case .error:
            self.states[0] = false
            self.invalidNameUI()
        }
    }
    
    func phoneResult(result: CertificationUseCase.Results) {
        switch result {
        case .valid:
            self.validPhoneUI()
        case .error:
            self.invalidPhoneUI()
        }
    }
    
    func certificationResult(result: CertificationUseCase.Results) {
        switch result {
        case .valid:
            self.validCertificationUI()
        case .error:
            self.invalidCertificationUI()
        }
    }
}
