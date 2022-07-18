//
//  SignupVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/15.
//

import UIKit
import Combine

final class SignupVC: UIViewController {
    static let identifier = "SignupVC"
    /// for design
    @IBOutlet weak var searchIcon: UIImageView!
    @IBOutlet weak var graduationLabel: UILabel!
    @IBOutlet weak var graduationInputView: UIView!
    /// textField
    @IBOutlet weak var phoneNumTextField: UITextField!
    @IBOutlet weak var authNumTextField: UITextField!
    @IBOutlet weak var idTextField: UITextField!
    /// action
    @IBOutlet weak var postAuthButton: UIButton!
    @IBOutlet weak var checkAuthButton: UIButton!
    /// status line
    @IBOutlet weak var phoneStatusLine: UIView!
    @IBOutlet weak var authStatusLine: UIView!
    /// warning
    @IBOutlet weak var warningPhoneView: UIView!
    @IBOutlet weak var warningAuthView: UIView!
    /// majors
    @IBOutlet var majorButtons: [UIButton]!
    @IBOutlet var majorDetailButtons: [UIButton]!
    /// select agrees
    @IBOutlet var checkButtons: [UIButton]!
    @IBOutlet var longTextButtons: [UIButton]!
    /// complete
    @IBOutlet weak var signupCompleteButton: UIButton!
    /// for layout
    @IBOutlet weak var scrollView: UIScrollView!
    
    private lazy var segmentedControl = SegmentedControlView(buttons: [
        SegmentedButtonInfo(title: "재학") { [weak self] in
            print("재학")
        },
        SegmentedButtonInfo(title: "졸업") { [weak self] in
            print("졸업")
        }
    ])
    private var viewModel: LoginSignupVM?
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "회원가입"
        self.configureViewModel()
        self.configureUI()
        self.configureTextFieldDelegate()
        self.configureNotification()
        self.bindAll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func postAuthNumber(_ sender: Any) {
        guard let viewModel = viewModel,
              let phoneNumber = self.phoneNumTextField.text,
              viewModel.checkPhoneNumberFormat(phoneNumber) == true else {
            // 잘못된 전화번호 형식 표시
            self.phoneStatusLine.backgroundColor = UIColor.systemRed
            self.warningPhoneView.isHidden = false
            return
        }
        // auth 전송
        viewModel.requestPhoneAuth(withPhoneNumber: phoneNumber)
    }
    
    @IBAction func checkAuthNumber(_ sender: Any) {
        guard let authNumber = self.authNumTextField.text else { return }
        self.viewModel?.confirmAuthNumber(with: authNumber)
    }
    
    @IBAction func checkNameDuplicated(_ sender: Any) {
        
    }
    
    @IBAction func selectMajor(_ sender: UIButton) {
        self.majorButtons[sender.tag].isSelected.toggle()
        self.updateButtons(self.majorButtons, index: sender.tag)
    }
    
    @IBAction func selectMajorDetail(_ sender: UIButton) {
        self.majorDetailButtons[sender.tag].isSelected.toggle()
        self.updateButtons(self.majorDetailButtons, index: sender.tag)
    }
    
    
    @IBAction func showSchoolSelectPopup(_ sender: Any) {
        
    }
    
    @IBAction func selectAgree(_ sender: UIButton) {
        self.checkButtons[sender.tag].isSelected.toggle()
        if sender.tag == 0 {
            self.updateAllChecks(to: self.checkButtons[0].isSelected)
        }
    }
    
    @IBAction func showDetailPopup(_ sender: UIButton) {
        print(sender.tag)
    }
    
}

extension SignupVC {
    private func configureViewModel() {
        self.viewModel = LoginSignupVM(networkUseCase: NetworkUsecase(network: Network()))
    }
    
    private func configureUI() {
        self.searchIcon.setSVGTintColor(to: UIColor.getSemomunColor(.black))
        self.graduationInputView.addSubview(self.segmentedControl)
        NSLayoutConstraint.activate([
            self.segmentedControl.topAnchor.constraint(equalTo: self.graduationLabel.bottomAnchor, constant: 16),
            self.segmentedControl.leadingAnchor.constraint(equalTo: self.graduationInputView.leadingAnchor)
        ])
        self.segmentedControl.selectIndex(to: 0)
    }
    
    private func configureTextFieldDelegate() {
        self.phoneNumTextField.delegate = self
        self.authNumTextField.delegate = self
        self.idTextField.delegate = self
    }
    
    private func configureNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
}

extension SignupVC {
    private func bindAll() {
        self.bindStatus()
    }
    
    private func bindStatus() {
        self.viewModel?.$status
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                switch status {
                case .phoneNumberInvalid:
                    self?.phoneStatusLine.backgroundColor = UIColor.systemRed
                    self?.warningPhoneView.isHidden = false
                case .phoneNumberValid:
                    self?.phoneStatusLine.backgroundColor = UIColor.getSemomunColor(.border)
                    self?.warningPhoneView.isHidden = true
                case .authCodeSent:
                    self?.phoneNumTextField.isUserInteractionEnabled = false
                    self?.authNumTextField.becomeFirstResponder()
                case .wrongAuthCode:
                    self?.authStatusLine.backgroundColor = UIColor.systemRed
                    self?.warningAuthView.isHidden = false
                case .authComplete:
                    self?.authNumTextField.isUserInteractionEnabled = false
                    self?.idTextField.becomeFirstResponder()
                    
                    self?.authStatusLine.backgroundColor = UIColor.getSemomunColor(.border)
                    self?.warningAuthView.isHidden = true
                    self?.checkAuthButton.setTitle("인증 완료", for: .normal)
                    self?.updateClickable(to: false, target: self?.postAuthButton)
                    self?.updateClickable(to: false, target: self?.checkAuthButton)
                case .usernameAlreadyUsed:
                    print("hello")
                case .usernameAvailable:
                    print("hello")
                case .usernameInvalid:
                    print("hello")
                case .usernameValid:
                    print("hello")
                case .userInfoComplete:
                    print("hello")
                case .userInfoIncomplete:
                    print("hello")
                case .none:
                    break
                }
            }
            .store(in: &self.cancellables)
    }
}

extension SignupVC {
    private func updateButtons(_ buttons: [UIButton], index: Int) {
        for (idx, button) in buttons.enumerated() {
            if idx == index {
                button.backgroundColor = UIColor.getSemomunColor(.orangeRegular)
                button.setTitleColor(UIColor.getSemomunColor(.white), for: .normal)
                button.layer.borderColor = UIColor.clear.cgColor
            } else {
                button.backgroundColor = UIColor.getSemomunColor(.white)
                button.setTitleColor(UIColor.getSemomunColor(.lightGray), for: .normal)
                button.layer.borderColor = UIColor.getSemomunColor(.border).cgColor
            }
        }
    }
    
    private func updateAllChecks(to: Bool) {
        self.checkButtons.forEach { $0.isSelected = to }
    }
    
    private func updateClickable(to: Bool, target: UIButton?) {
        target?.isUserInteractionEnabled = to
        target?.backgroundColor = to ? UIColor.getSemomunColor(.blueRegular) : UIColor.systemGray4
    }
}

extension SignupVC {
    private func configureUIForAuthCanceled() {
//        self.getAuthNumButton.isHidden = false
//        self.requestAgainButton.isHidden = true
//        self.verifyAuthNumButton.isHidden = true
//
//        self.authNumTextField.isEnabled = false
//        self.authNumTextField.text = ""
//
//        self.coloredFrameLabels[1].isHidden = true
//        self.coloredFrameLabels[2].isHidden = true
//
//        self.phoneNumTextFieldTrailingConstraint.constant = self.phoneNumTextFieldTrailingMargin
    }
}

extension SignupVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text, let textRange = Range(range, in: text) else {
            return true
        }

        // replacementString이 적용된 최종 text
        let updatedText = text.replacingCharacters(in: textRange, with: string)

        switch textField {
        case self.phoneNumTextField:
            self.updateClickable(to: updatedText.count > 10, target: self.postAuthButton)
            return true
        case self.authNumTextField:
            self.updateClickable(to: updatedText.count == 6, target: self.checkAuthButton)
            return true
        case self.idTextField:
            return true
        default:
            return true
        }
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField == self.phoneNumTextField {
            return self.isPhoneNumberChangeAvailable()
        } else if textField == self.idTextField {
            self.viewModel?.invalidateUsername()
            return true
        } else {
            return true
        }
    }

    // 인증 중이거나 인증이 완료된 경우 Alert을 띄우고 false를 반환
    private func isPhoneNumberChangeAvailable() -> Bool {
        if self.viewModel?.canChangePhoneNumber == false {
            self.showAlertWithCancelAndOK(title: "전화번호 수정", text: "다른 전화번호로 다시 진행하시겠습니까?") { [weak self] in
                self?.configureUIForAuthCanceled()
                self?.viewModel?.cancelAuth()
            }
            return false
        }
        return true
    }

    @objc func keyboardWillChangeFrame(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }

        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: frame.height, right: 0)
        self.scrollView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification: Notification) {
        self.scrollView.contentInset = UIEdgeInsets.zero
    }
}
