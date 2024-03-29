//
//  ChangeUserinfoPopupVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import SwiftUI
import Combine

final class ChangeUserInfoVC: UIViewController {
    
    static let storyboardName = "Profile"
    static let identifier = "ChangeUserInfoVC"
    
    private var viewModel: ChangeUserInfoVM?
    private var schoolSearchView: UIHostingController<LoginSchoolSearchView>?
    private var cancellables: Set<AnyCancellable> = []
    private var coloredFrameLabels: [ColoredFrameLabel] = []
    
    private var isAuthPhoneTFShown = false {
        didSet {
            if self.isAuthPhoneTFShown {
                self.prepareToShowPhoneNumFrame()
            } else {
                self.prepareToHidePhoneNumFrame()
            }
        }
    }
    
    @IBOutlet weak var bodyFrame: UIView!
    
    @IBOutlet weak var nicknameFrame: UIView!
    @IBOutlet weak var nickname: UITextField!
    
    @IBOutlet weak var phoneNumFrame: UIView!
    @IBOutlet weak var phoneNumTextField: UITextField!
    @IBOutlet weak var changePhoneNumButton: UIButton!
    
    @IBOutlet weak var phoneNumberAuthFrame: UIView!
    @IBOutlet weak var phoneNumberAuthTextField: UITextField!
    @IBOutlet weak var authPhoneNumButton: UIButton!
    @IBOutlet weak var requestAgainButton: UIButton!
    
    @IBOutlet weak var majorCollectionView: UICollectionView!
    @IBOutlet weak var majorDetailCollectionView: UICollectionView!
    
    @IBOutlet weak var schoolFinder: UIButton!
    @IBOutlet weak var graduationStatusSelector: UIButton!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var additionalTextFieldTrailingConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureDelegate()
        self.bindAll()
        self.viewModel?.fetchData()
        self.configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func checkNickname(_ sender: Any) {
        guard let username = self.nickname.text else { return }
        self.viewModel?.changeUsername(username)
    }
    
    @IBAction func changePhoneNum(_ sender: Any) {
        self.isAuthPhoneTFShown.toggle()
        
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    @IBAction func requestOrConfirmAuth(_ sender: UIButton) {
        if sender.titleLabel?.text == "인증확인" {
            //인증확인
            guard let authNum = self.phoneNumberAuthTextField.text else { return }
            self.viewModel?.confirmAuthNumber(with: authNum)
        } else {
            //인증요청
            guard let newPhoneStr = self.phoneNumberAuthTextField.text else { return }
            self.viewModel?.requestPhoneAuth(withPhoneNumber: newPhoneStr)
        }
    }
    
    @IBAction func requestAuthAgain(_ sender: Any) {
        self.viewModel?.requestAuthAgain()
    }
    
    @IBAction func submit(_ sender: Any) {
        guard self.nickname.text == self.viewModel?.newUserInfo?.username else {
            self.showAlertWithOK(title: "닉네임 중복확인이 필요합니다", text: "")
            return
        }
        self.viewModel?.submit { [weak self] success in
            guard success else { return }
            self?.showAlertWithOK(title: "저장 완료", text: "계정 정보가 저장되었습니다.") { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
}

extension ChangeUserInfoVC {
    func configureVM(_ viewModel: ChangeUserInfoVM) {
        self.viewModel = viewModel
    }
}

// MARK: Configure UI
extension ChangeUserInfoVC {
    private func configureUI() {
        self.navigationItem.title = "개인정보 수정"
        self.navigationItem.titleView?.backgroundColor = .white
        self.configureButtonMenus()
        self.phoneNumberAuthFrame.isHidden = true
        self.requestAgainButton.isHidden = true
        self.bodyFrame.layer.cornerRadius = 15
        self.bodyFrame.addShadow(direction: .top)
        self.configureColoredFrameLabels()
    }
    private func configureButtonUI(button: UIButton, isFilled: Bool) {
        let buttonColor = UIColor(.deepMint)
        if isFilled {
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = buttonColor
            button.borderColor = .white
        } else {
            button.setTitleColor(buttonColor, for: .normal)
            button.backgroundColor = .white
            button.borderColor = buttonColor
        }
    }
    private func prepareToShowPhoneNumFrame() {
        self.viewModel?.invalidatePhonenumber()
        
        self.changePhoneNumButton.setTitle("취소", for: .normal)
        self.phoneNumberAuthFrame.isHidden = false
        self.phoneNumberAuthTextField.placeholder = "변경할 전화번호를 입력해주세요."
        self.phoneNumberAuthTextField.becomeFirstResponder()
        self.phoneNumberAuthTextField.text = nil
        self.requestAgainButton.isHidden = true
        self.additionalTextFieldTrailingConstraint.constant = 12
        
        self.authPhoneNumButton.setTitle("인증요청", for: .normal)
        self.configureButtonUI(button: self.authPhoneNumButton, isFilled: true)
    }
    private func prepareToHidePhoneNumFrame() {
        self.viewModel?.cancelAuth()
        
        self.changePhoneNumButton.setTitle("변경", for: .normal)
        self.phoneNumberAuthFrame.isHidden = true
        self.phoneNumberAuthTextField.resignFirstResponder()
        self.coloredFrameLabels[1].isHidden = true
    }
}

// MARK: Configure ColoredFrameLabel
extension ChangeUserInfoVC {
    private func configureColoredFrameLabels() {
        self.coloredFrameLabels = (0..<2).map { _ in ColoredFrameLabel() }
        self.coloredFrameLabels.forEach { $0.isHidden = true }
        self.addFrameLabel(self.coloredFrameLabels[0], to: self.nicknameFrame)
        self.addFrameLabel(self.coloredFrameLabels[1], to: self.phoneNumberAuthFrame)
    }
    
    private func addFrameLabel(_ label: ColoredFrameLabel, to frame: UIView) {
        label.translatesAutoresizingMaskIntoConstraints = false
        frame.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: frame.leadingAnchor),
            label.topAnchor.constraint(equalTo: frame.bottomAnchor, constant: 3)
        ])
    }
}

// MARK: Configure delegates
extension ChangeUserInfoVC {
    private func configureDelegate() {
        self.majorCollectionView.dataSource = self
        self.majorCollectionView.delegate = self
        
        self.majorDetailCollectionView.dataSource = self
        self.majorDetailCollectionView.delegate = self
        
        self.phoneNumberAuthTextField.delegate = self
        self.nickname.delegate = self
    }
}

// MARK: Configure Menus
extension ChangeUserInfoVC {
    private func configureButtonMenus() {
        self.configureSchoolButtonMenu()
        self.configureSchoolStatusMenu()
    }
    private func configureSchoolButtonMenu() {
        let menuItems: [UIAction] = SchoolSearchUseCase.SchoolType.allCases.map { schoolType in
            UIAction(title: schoolType.rawValue, image: nil, handler: { [weak self] _ in
                self?.schoolSearchView = UIHostingController(rootView: LoginSchoolSearchView(delegate: self, schoolType: schoolType))
                self?.schoolSearchView?.view.backgroundColor = .clear
                if let view = self?.schoolSearchView {
                    self?.present(view, animated: true, completion: nil)
                }
            })
        }
        self.schoolFinder.menu = UIMenu(title: "학교 선택", image: nil, identifier: nil, options: [], children: menuItems)
        self.schoolFinder.showsMenuAsPrimaryAction = true
    }
    private func configureSchoolStatusMenu() {
        let graduationMenuItems: [UIAction] = ["재학", "졸업"].map { description in
            return UIAction(title: description, image: nil) { [weak self] _ in
                self?.viewModel?.selectGraduationStatus(description)
            }
        }
        self.graduationStatusSelector.menu = UIMenu(title: "대학 / 졸업 선택", options: [], children: graduationMenuItems)
        self.graduationStatusSelector.showsMenuAsPrimaryAction = true
    }
}

// MARK: Bind
extension ChangeUserInfoVC {
    private func bindAll() {
        self.bindUserInfo()
        self.bindAlert()
        self.bindStatus()
        self.bindData()
        self.bindConfigureUIForNicknamePhoneRequest()
    }
    private func bindData() {
        self.viewModel?.$majors
            .receive(on: DispatchQueue.main)
            .sink { [weak self] signupUserInfo in
                self?.majorCollectionView.reloadData()
            }
            .store(in: &self.cancellables)
        self.viewModel?.$majorDetails
            .receive(on: DispatchQueue.main)
            .sink { [weak self] signupUserInfo in
                self?.majorDetailCollectionView.reloadData()
            }
            .store(in: &self.cancellables)
        
    }
    private func bindUserInfo() {
        self.viewModel?.$currentUserInfo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userInfo in
                guard let userInfo = userInfo else { return }
                self?.nickname.text = userInfo.username
                self?.phoneNumTextField.placeholder = userInfo.phoneNumber
            }
            .store(in: &self.cancellables)
        self.viewModel?.$newUserInfo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userInfo in
                guard let userInfo = userInfo else { return }
                self?.majorCollectionView.reloadData()
                self?.majorDetailCollectionView.reloadData()
                self?.schoolFinder.setTitle(userInfo.school, for: .normal)
                self?.graduationStatusSelector.setTitle(userInfo.graduationStatus, for: .normal)
            }
            .store(in: &self.cancellables)
    }
    
    private func bindStatus() {
        self.viewModel?.$status
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                switch status {
                case .usernameInvalid:
                    self?.coloredFrameLabels[0].configure(type: .warning("5~20자의 숫자와 알파벳(최소 하나), 언더바(_)의 조합이 가능합니다."))
                case .usernameValid:
                    self?.coloredFrameLabels[0].isHidden = true
                    
                case .phoneNumberInvalid:
                    self?.coloredFrameLabels[1].configure(type: .warning("10-11자리의 숫자를 입력해주세요."))
                case .phoneNumberValid:
                    self?.coloredFrameLabels[1].isHidden = true
                    
                case .authCodeSent:
                    self?.coloredFrameLabels[1].isHidden = true
                    self?.changeAdditionalTFForAuthNum()
                case .wrongAuthCode:
                    self?.coloredFrameLabels[1].configure(type: .warning("잘못된 인증번호입니다"))
                case .authComplete:
                    self?.isAuthPhoneTFShown = false
                    guard let button = self?.changePhoneNumButton else { break }
                    self?.configureButtonUI(button: button, isFilled: false)
                    button.setTitle("인증완료", for: .normal)
                    button.isEnabled = false
                    
                case .usernameAlreadyUsed:
                    self?.coloredFrameLabels[0].configure(type: .warning("사용할 수 없는 닉네임입니다."))
                case .usernameAvailable:
                    self?.nickname.resignFirstResponder()
                    self?.coloredFrameLabels[0].configure(type: .success("사용가능한 닉네임입니다."))
                    
                case .userInfoComplete:
                    self?.submitButton.backgroundColor = UIColor(.mainColor)
                case .userInfoIncomplete:
                    self?.submitButton.backgroundColor = UIColor(.semoLightGray)
                    
                case .none:
                    break
                }
            }
            .store(in: &self.cancellables)
    }
    private func bindConfigureUIForNicknamePhoneRequest() {
        self.viewModel?.$configureUIForNicknamePhoneRequest
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard status else { return }
                self?.phoneNumTextField.placeholder = "전화번호 정보 없음"
            }
            .store(in: &self.cancellables)
    }
    private func bindAlert() {
        self.viewModel?.$alert
            .receive(on: DispatchQueue.main)
            .sink { [weak self] alert in
                switch alert {
                case .alertWithoutPop(title: let title, description: let description):
                    self?.showAlertWithOK(title: title, text: description ?? "")
                case .alertWithPop(title: let title, description: let description):
                    self?.showAlertWithOK(title: title, text: description ?? "") {
                        self?.navigationController?.popViewController(animated: true)
                    }
                case .none:
                    break
                }
            }
            .store(in: &self.cancellables)
    }
    private func changeAdditionalTFForAuthNum() {
        self.requestAgainButton.isHidden = false
        self.additionalTextFieldTrailingConstraint.constant = 12 + self.requestAgainButton.frame.width
        self.authPhoneNumButton.setTitle("인증확인", for: .normal)
        self.phoneNumberAuthTextField.text = nil
        self.phoneNumberAuthTextField.placeholder = "인증번호를 입력해주세요."
        self.configureButtonUI(button: self.authPhoneNumButton, isFilled: false)
    }
}

// MARK: UICollectionView
extension ChangeUserInfoVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == majorCollectionView {
            self.viewModel?.selectMajor(at: indexPath.item)
        } else {
            self.viewModel?.selectMajorDetail(at: indexPath.item)
        }
        collectionView.reloadData()
    }
}

extension ChangeUserInfoVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == majorCollectionView {
            return self.viewModel?.majors.count ?? 0
        } else {
            return self.viewModel?.majorDetails.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MajorCollectionViewCell.identifier, for: indexPath) as? MajorCollectionViewCell else { return UICollectionViewCell() }
        if collectionView == majorCollectionView {
            guard let majorName = self.viewModel?.majors[indexPath.item] else { return cell }
            if majorName == self.viewModel?.newUserInfo?.major {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init())
            }
            cell.configureText(major: majorName)
            return cell
        } else {
            guard let majorDetailName = self.viewModel?.majorDetails[indexPath.item] else { return cell }
            if majorDetailName == self.viewModel?.newUserInfo?.majorDetail {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init())
            }
            cell.configureText(major: majorDetailName)
            return cell
        }
    }
}

extension ChangeUserInfoVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView == majorCollectionView ? CGSize(133, 39) : CGSize(68, 39)
    }
}

// MARK: 학교 팝업 Delegate
extension ChangeUserInfoVC: SchoolSelectAction {
    func schoolSelected(_ name: String) {
        self.dismissKeyboard()
        self.viewModel?.selectSchool(name)
        self.schoolFinder.setTitle(name, for: .normal)
        self.schoolSearchView?.dismiss(animated: true, completion: nil)
    }
}

extension ChangeUserInfoVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text, let textRange = Range(range, in: text), let vm = self.viewModel else {
            return true
        }
        
        // replacementString이 적용된 최종 text
        let updatedText = text.replacingCharacters(in: textRange, with: string)
        
        switch textField {
        case self.phoneNumberAuthTextField:
            if self.requestAgainButton.isHidden {
                // 전화번호 입력
                return vm.checkPhoneNumberFormat(updatedText)
            } else {
                // 인증 번호 입력
                // TODO: 인증번호 유효성 로직도 VM에 추가
                return updatedText.isNumber
            }
        case self.nickname:
            vm.invalidateUsername()
            return vm.checkUsernameFormat(updatedText)
        default:
            return true
        }
    }
}
