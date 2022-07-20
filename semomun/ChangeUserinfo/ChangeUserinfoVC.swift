//
//  ChangeUserinfoVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/19.
//

import UIKit
import Combine

final class ChangeUserinfoVC: UIViewController {
    static let identifier = "ChangeUserinfoVC"
    static let storyboardName = "Profile"
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
    /// for layout
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewLeading: NSLayoutConstraint!
    private lazy var changeCompleteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
        button.titleLabel?.font = UIFont.heading5
        button.setTitleColor(UIColor.getSemomunColor(.lightGray), for: .normal)
        button.setTitle("저장", for: .normal)
        button.setImageWithSVGTintColor(image: UIImage(.pencilAltOutline), color: .lightGray)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 0)
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 51),
            button.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        button.addAction(UIAction(handler: { [weak self] _ in
            guard self?.viewModel?.validResult == true else { return }
            self?.viewModel?.submit()
        }), for: .touchUpInside)
        
        return button
    }()
    private lazy var segmentedControl = SegmentedControlView(buttons: [
        SegmentedButtonInfo(title: "재학") { [weak self] in
            self?.viewModel?.selectGraduationStatus("재학")
        },
        SegmentedButtonInfo(title: "졸업") { [weak self] in
            self?.viewModel?.selectGraduationStatus("졸업")
        }
    ])
    private var viewModel: ChangeUserinfoVM?
    private var cancellables: Set<AnyCancellable> = []
    private var selectedMajorIndex: Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "개인정보 수정"
        self.configureViewModel()
        self.configureUI()
        self.configureCompleteButton()
        self.configureTextField()
        self.configureTextFieldDelegate()
        self.configureNotification()
        self.bindAll()
        
        self.viewModel?.getUserInfo()
        print(self.view.bounds)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { [weak self] _ in
            let leading: CGFloat = UIWindow.isLandscape ? 180 : 0
            self?.scrollViewLeading.constant = leading
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
        guard let schoolSelectPopupVC = UIStoryboard(name: SchoolSelectPopupVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: SchoolSelectPopupVC.identifier) as? SchoolSelectPopupVC else { return }
        schoolSelectPopupVC.configureDelegate(self)
        self.present(schoolSelectPopupVC, animated: true)
    }
}

extension ChangeUserinfoVC {
    private func configureViewModel() {
        self.viewModel = ChangeUserinfoVM(networkUseCase: NetworkUsecase(network: Network()))
    }
    
    private func configureUI() {
        self.searchIcon.setSVGTintColor(to: UIColor.getSemomunColor(.black))
        self.graduationInputView.addSubview(self.segmentedControl)
        NSLayoutConstraint.activate([
            self.segmentedControl.topAnchor.constraint(equalTo: self.graduationLabel.bottomAnchor, constant: 16),
            self.segmentedControl.leadingAnchor.constraint(equalTo: self.graduationInputView.leadingAnchor)
        ])
        self.segmentedControl.selectIndex(to: 0)
        
        let leading: CGFloat = UIWindow.isLandscape ? 180 : 0
        self.scrollViewLeading.constant = leading
    }
    
    private func configureCompleteButton() {
        self.navigationItem.setRightBarButton(UIBarButtonItem(customView: self.changeCompleteButton), animated: true)
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

extension ChangeUserinfoVC {
    private func bindAll() {
        self.bindUserinfo()
        self.bindStatus()
        self.bindMajorDetails()
        self.bindAlert()
        self.bindUpdateSuccess()
        self.bindOfflineError()
    }
    
    private func bindUserinfo() {
        self.viewModel?.$currentUserInfo
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] userinfo in
                guard let userinfo = userinfo else { return }
                self?.configureDatas(userinfo)
            })
            .store(in: &self.cancellables)
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
                    self?.phoneWarniingLabel.text = "인증 횟수 초과. 1시간 후 다시 시도해주세요"
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
                    self?.changeCompleteButton.isUserInteractionEnabled = true
                    self?.changeCompleteButton.setTitleColor(UIColor.getSemomunColor(.blueRegular), for: .normal)
                    self?.changeCompleteButton.setImageWithSVGTintColor(image: UIImage(.pencilAltOutline), color: .blueRegular)
                case .userInfoIncomplete:
                    self?.changeCompleteButton.isUserInteractionEnabled = false
                    self?.changeCompleteButton.setTitleColor(UIColor.getSemomunColor(.lightGray), for: .normal)
                    self?.changeCompleteButton.setImageWithSVGTintColor(image: UIImage(.pencilAltOutline), color: .lightGray)
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
    
    private func bindUpdateSuccess() {
        self.viewModel?.$updateUserinfoSuccess
            .dropFirst()
            .sink(receiveValue: { [weak self] success in
                guard success == true else { return }
                self?.navigationController?.popViewController(animated: true)
            })
            .store(in: &self.cancellables)
    }
    
    private func bindOfflineError() {
        self.viewModel?.$offlineError
            .dropFirst()
            .sink(receiveValue: { [weak self] offline in
                guard offline == true else { return }
                self?.showAlertWithOK(title: "네트워크 에러", text: "네트워크가 연결되어있지 않습니다.", completion: { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                })
            })
            .store(in: &self.cancellables)
    }
}

extension ChangeUserinfoVC {
    private func configureDatas(_ userinfo: UserInfo) {
        guard let viewModel = self.viewModel else { return }
        
        self.phoneNumTextField.text = userinfo.phoneNumber ?? ""
        self.idTextField.text = userinfo.username
        
        var majorIndex = 0
        for (idx, button) in self.majorButtons.enumerated() {
            if button.currentTitle == userinfo.major {
                majorIndex = idx
                self.selectButton(button)
            } else {
                self.deSelectButton(button)
            }
        }
        self.selectedMajorIndex = majorIndex
        self.viewModel?.configureMajorDetails(majorIndex: majorIndex)
        
        let majorDetailDatas = viewModel.majorRawValues[majorIndex]
        for (idx, detail) in majorDetailDatas.enumerated() {
            self.majorDetailButtons[idx].setTitle(detail, for: .normal)
            if detail == userinfo.majorDetail {
                self.selectButton(self.majorDetailButtons[idx])
            } else {
                self.deSelectButton(self.majorDetailButtons[idx])
            }
        }
        
        self.schoolButton.setTitle(userinfo.school, for: .normal)
        if userinfo.graduationStatus == "졸업" {
            self.segmentedControl.selectIndex(to: 1)
        }
    }
    
    private func updateButtons(_ buttons: [UIButton], index: Int?) {
        for (idx, button) in buttons.enumerated() {
            if idx == index {
                self.selectButton(button)
            } else {
                self.deSelectButton(button)
            }
        }
    }
    
    private func selectButton(_ button: UIButton) {
        button.backgroundColor = UIColor.getSemomunColor(.orangeRegular)
        button.setTitleColor(UIColor.getSemomunColor(.white), for: .normal)
        button.layer.borderColor = UIColor.clear.cgColor
    }
    
    private func deSelectButton(_ button: UIButton) {
        button.backgroundColor = UIColor.getSemomunColor(.white)
        button.setTitleColor(UIColor.getSemomunColor(.lightGray), for: .normal)
        button.layer.borderColor = UIColor.getSemomunColor(.border).cgColor
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

extension ChangeUserinfoVC: UITextFieldDelegate {
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

extension ChangeUserinfoVC: SchoolSelectDelegate {
    func selectSchool(to schoolName: String) {
        self.schoolButton.setTitle(schoolName, for: .normal)
        self.schoolButton.setTitleColor(UIColor.getSemomunColor(.darkGray), for: .normal)
        self.viewModel?.selectSchool(schoolName)
    }
}
