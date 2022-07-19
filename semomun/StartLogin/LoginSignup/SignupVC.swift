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
    @IBOutlet weak var checkIdButton: UIButton!
    @IBOutlet weak var schoolButton: UIButton!
    /// status line
    @IBOutlet weak var phoneStatusLine: UIView!
    @IBOutlet weak var authStatusLine: UIView!
    @IBOutlet weak var idStatusLine: UIView!
    /// warning
    @IBOutlet weak var warningPhoneView: UIView!
    @IBOutlet weak var warningAuthView: UIView!
    @IBOutlet weak var phoneWarniingLabel: UILabel!
    @IBOutlet weak var idWarningLabel: UILabel!
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
    @IBOutlet weak var completeButtonHeight: NSLayoutConstraint!
    
    private lazy var segmentedControl = SegmentedControlView(buttons: [
        SegmentedButtonInfo(title: "재학") { [weak self] in
            self?.viewModel?.selectGraduationStatus("재학")
        },
        SegmentedButtonInfo(title: "졸업") { [weak self] in
            self?.viewModel?.selectGraduationStatus("졸업")
        }
    ])
    private var agreeChecks: [Bool] = Array(repeating: false, count: 4) {
        didSet {
            self.viewModel?.selectMarketing(to: agreeChecks[3])
        }
    }
    private var agreeCompleted: Bool {
        return agreeChecks[1] && agreeChecks[2]
    }
    private var viewModel: SignupVM?
    private var cancellables: Set<AnyCancellable> = []
    private var selectedMajorIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "회원가입"
        self.configureViewModel()
        self.configureUI()
        self.configureTextField()
        self.configureTextFieldDelegate()
        self.configureNotification()
        self.bindAll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        /// homebar 가 존재하는 디바이스의 경우 하단 완료 버튼 layout 수정
        if view.safeAreaInsets.bottom > 0 {
            self.completeButtonHeight.constant = 73+20
            self.signupCompleteButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        }
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
        guard let id = self.idTextField.text else { return }
        self.viewModel?.checkIDDuplicated(id)
    }
    
    @IBAction func selectMajor(_ sender: UIButton) {
        self.selectedMajorIndex = sender.tag
        self.updateButtons(self.majorButtons, index: sender.tag)
        self.updateButtons(self.majorDetailButtons, index: nil)
        self.viewModel?.selectMajor(to: sender.tag)
    }
    
    @IBAction func selectMajorDetail(_ sender: UIButton) {
        guard let selectedMajorIndex = self.selectedMajorIndex,
              let major = self.majorButtons[selectedMajorIndex].titleLabel?.text else { return }
        self.updateButtons(self.majorDetailButtons, index: sender.tag)
        self.viewModel?.selectMajorDetail(major: major, detailIndex: sender.tag)
    }
    
    @IBAction func showSchoolSelectPopup(_ sender: Any) {
        guard let schoolSelectPopupVC = self.storyboard?.instantiateViewController(withIdentifier: SchoolSelectPopupVC.identifier) as? SchoolSelectPopupVC else { return }
        schoolSelectPopupVC.configureDelegate(self)
        self.present(schoolSelectPopupVC, animated: true)
    }
    
    @IBAction func selectAgree(_ sender: UIButton) {
        self.checkButtons[sender.tag].isSelected.toggle()
        self.agreeChecks[sender.tag].toggle()
        
        if sender.tag == 0 {
            let status = self.agreeChecks[0]
            self.agreeChecks = Array(repeating: status, count: 4)
            self.updateAllChecks(to: status)
        }
    }
    
    @IBAction func showDetailPopup(_ sender: UIButton) {
        guard let longTextPopupVC = self.storyboard?.instantiateViewController(withIdentifier: LongTextPopupVC.identifier) as? LongTextPopupVC else { return }
        
        switch sender.tag {
        case 1: longTextPopupVC.text = .personalInformationProcessingPolicy
        case 2: longTextPopupVC.text = .termsAndConditions
        case 3: longTextPopupVC.text = .receiveMarketingInfo
        default: return
        }
        
        self.present(longTextPopupVC, animated: true)
    }
    
    @IBAction func signupComplete(_ sender: Any) {
        let networkUsecase = NetworkUsecase(network: Network())
        let viewModel = SearchTagVM(networkUsecase: networkUsecase)
        let searchTagVC = SearchTagVC(viewModel: viewModel, mode: .signup)
        self.present(searchTagVC, animated: true, completion: nil)
    }
}

extension SignupVC {
    private func configureViewModel() {
        self.viewModel = SignupVM(networkUseCase: NetworkUsecase(network: Network()))
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
    
    private func configureTextField() {
        self.phoneNumTextField.keyboardType = .numberPad
        self.authNumTextField.keyboardType = .numberPad
        self.idTextField.keyboardType = .alphabet
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
        self.bindMajorDetails()
        self.bindShowSocialSignupVC()
        self.bindAlert()
    }
    
    private func bindStatus() {
        self.viewModel?.$status
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                switch status {
                case .phoneNumberInvalid:
                    self?.phoneStatusLine.backgroundColor = UIColor.systemRed
                    self?.warningPhoneView.isHidden = false
                case .smsLimitExceed:
                    self?.phoneStatusLine.backgroundColor = UIColor.systemRed
                    self?.phoneWarniingLabel.text = "인증 회수 초과. 1시간 후 다시 시도해주세요"
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
                case .usernameInvalid:
                    self?.idWarningLabel.text = "잘못된 형식입니다. 5~20자의 숫자와 영문자, 언더바(_)의 조합"
                    self?.idStatusLine.backgroundColor = UIColor.systemRed
                    self?.idWarningLabel.textColor = UIColor.systemRed
                case .usernameAlreadyUsed:
                    self?.idWarningLabel.text = "중복된 아이디입니다. 5~20자의 숫자와 영문자, 언더바(_)의 조합"
                    self?.idStatusLine.backgroundColor = UIColor.systemRed
                    self?.idWarningLabel.textColor = UIColor.systemRed
                case .usernameAvailable:
                    self?.idStatusLine.backgroundColor = UIColor.systemGray4
                    self?.idWarningLabel.text = "사용 가능한 아이디입니다"
                    self?.idWarningLabel.textColor = UIColor.systemGreen
                    self?.dismissKeyboard()
                case .userInfoComplete:
                    let completeable = self?.agreeCompleted == true
                    if completeable {
                        self?.signupCompleteButton.isUserInteractionEnabled = true
                        self?.signupCompleteButton.backgroundColor = UIColor.getSemomunColor(.orangeRegular)
                    } else {
                        self?.signupCompleteButton.isUserInteractionEnabled = false
                        self?.signupCompleteButton.backgroundColor = UIColor.systemGray4
                    }
                case .userInfoIncomplete:
                    self?.signupCompleteButton.isUserInteractionEnabled = false
                    self?.signupCompleteButton.backgroundColor = UIColor.systemGray4
                case .none:
                    break
                }
            }
            .store(in: &self.cancellables)
    }
    
    private func bindMajorDetails() {
        self.viewModel?.$majorDetails
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] details in
                self?.majorDetailButtons[4].isHidden = details.count == 4
                self?.updateDetailButtonTitles(details)
            })
            .store(in: &self.cancellables)
    }
    
    private func bindShowSocialSignupVC() {
        self.viewModel?.$showSocialSignupVC
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] isShow in
                guard isShow == true else { return }
                guard let self = self else { return }
                guard let selectSocialSignupPopupVC = self.storyboard?.instantiateViewController(withIdentifier: SelectSocialSignupPopupVC.identifier) as? SelectSocialSignupPopupVC else { return }
                guard let userInfo = self.viewModel?.signupUserInfo else { return }
                let usecase = SignupUsecase(userInfo: userInfo, networkUsecase: NetworkUsecase(network: Network()))
                selectSocialSignupPopupVC.configureDelegate(self)
                selectSocialSignupPopupVC.configureUsecase(usecase)
                self.present(selectSocialSignupPopupVC, animated: true)
            })
            .store(in: &self.cancellables)
    }
    
    private func bindAlert() {
        self.viewModel?.$alert
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] alert in
                switch alert {
                case .alert(title: let title, description: let description):
                    self?.showAlertWithOK(title: title, text: description ?? "")
                case .none:
                    return
                }
            })
            .store(in: &self.cancellables)
    }
}

extension SignupVC {
    private func updateButtons(_ buttons: [UIButton], index: Int?) {
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
    
    private func updateDetailButtonTitles(_ details: [String]) {
        for (idx, title) in details.enumerated() {
            self.majorDetailButtons[idx].setTitle(title, for: .normal)
        }
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
            self.updateClickable(to: updatedText.count > 8, target: self.postAuthButton)
            return true
        case self.authNumTextField:
            self.updateClickable(to: updatedText.count == 6, target: self.checkAuthButton)
            return true
        case self.idTextField:
            self.viewModel?.invalidateUsername() // id 정보 nil 로 설정
            let clickable = updatedText.count > 4 && updatedText.count < 21
            self.updateClickable(to: clickable, target: self.checkIdButton)
            return true
        default:
            return true
        }
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

extension SignupVC: SchoolSelectDelegate {
    func selectSchool(to schoolName: String) {
        self.schoolButton.setTitle(schoolName, for: .normal)
        self.schoolButton.setTitleColor(UIColor.getSemomunColor(.darkGray), for: .normal)
        self.viewModel?.selectSchool(schoolName)
    }
}

extension SignupVC: SignupCompleteable {
    func signupComplete() {
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] _ in
            self?.presentingViewController?.dismiss(animated: true, completion: nil)
            NotificationCenter.default.post(name: .logined, object: nil)
        }
    }
}
