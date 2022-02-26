//
//  LoginSignupVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import Combine
import SwiftUI

final class LoginSignupVC: UIViewController {
    static let identifier = "LoginSignupVC"
    static let storyboardName = "StartLogin"
    
    private var viewModel: ChangeUserInfoVM?
    private var schoolSearchView: UIHostingController<LoginSchoolSearchView>?
    private var cancellables: Set<AnyCancellable> = []
    private var coloredFrameLabels: [ColoredFrameLabel] = []
    
    @IBOutlet weak var bodyFrame: UIView!
    
    @IBOutlet weak var nicknameFrame: UIView!
    @IBOutlet weak var nickname: UITextField!
    
    @IBOutlet weak var phonenumFrame: UIView!
    @IBOutlet weak var phonenumTextField: UITextField!
    @IBOutlet weak var getAuthNumButton: UIButton!
    
    @IBOutlet weak var authNumFrame: UIView!
    @IBOutlet weak var authNumTextField: UITextField!
    @IBOutlet weak var verifyAuthNumButton: UIButton!
    @IBOutlet weak var requestAgainButton: UIButton!
    
    @IBOutlet weak var majorCollectionView: UICollectionView!
    @IBOutlet weak var majorDetailCollectionView: UICollectionView!
    
    @IBOutlet weak var schoolFinder: UIButton!
    @IBOutlet weak var graduationStatusSelector: UIButton!
    
    @IBOutlet weak var phoneNumTextFieldTrailingConstraint: NSLayoutConstraint!
    
    private var phoneNumTextFieldTrailingMargin: CGFloat = 12
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViewModel()
        self.configureUI()
        self.configureTableViewDelegate()
        self.configureTextFieldDelegate()
        self.bindAll()
        self.phoneNumTextFieldTrailingMargin = self.phoneNumTextFieldTrailingConstraint.constant
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func checkNickname(_ sender: Any) {
        guard let nickname = self.nickname.text else { return }
        self.viewModel?.changeNicknameIfAvailable(nickname: nickname)
    }
    
    @IBAction func requestAuth(_ sender: Any) {
        guard let newPhoneStr = self.phonenumTextField.text else { return }
        self.viewModel?.requestPhoneAuth(withPhoneNumber: newPhoneStr)
    }
    
    @IBAction func confirmAuth(_ sender: UIButton) {
        guard let authNum = self.authNumTextField.text else { return }
        self.viewModel?.confirmAuthNumber(with: authNum)
    }
    
    @IBAction func requestAuthAgain(_ sender: Any) {
        self.viewModel?.requestPhoneAuthAgain()
    }
    
    @IBAction func submit(_ sender: Any) {
        guard let userInfo = self.viewModel?.makeUserInfo() else { return }
        if userInfo.isValidSurvay {
            guard let vc = UIStoryboard(name: LoginSelectVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: LoginSelectVC.identifier) as? LoginSelectVC else { return }
            vc.configurePopup(isNeeded: true)
            vc.configureSignupInfo(userInfo)
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.showAlertWithOK(title: "모든 정보를 입력해주세요", text: "")
        }
    }
    
    @IBAction func submitBypass(_ sender: Any) {
#if DEBUG
        guard let userInfo = self.viewModel?.makeUserInfo() else { return }
        guard let vc = UIStoryboard(name: LoginSelectVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: LoginSelectVC.identifier) as? LoginSelectVC else { return }
        vc.configurePopup(isNeeded: true)
        vc.configureSignupInfo(userInfo)
        self.navigationController?.pushViewController(vc, animated: true)
#endif
    }
    
}

// MARK: Configure UI
extension LoginSignupVC {
    private func configureUI() {
        self.navigationItem.title = "회원가입"
        self.navigationItem.titleView?.backgroundColor = .white
        self.configureButtonMenus()
        self.bodyFrame.layer.cornerRadius = 15
        self.bodyFrame.addShadow(direction: .top)
        self.configureColoredFrameLabels()
    }
    private func configureColoredFrameLabels() {
        self.coloredFrameLabels = (0..<3).map { _ in
            let label = ColoredFrameLabel()
            label.isHidden = true
            return label
        }
        self.addFrameLabel(self.coloredFrameLabels[0], to: self.nicknameFrame)
        self.addFrameLabel(self.coloredFrameLabels[1], to: self.phonenumFrame)
        self.addFrameLabel(self.coloredFrameLabels[2], to: self.authNumFrame)
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

// MARK: Configure ViewModel
extension LoginSignupVC {
    private func configureViewModel() {
        self.viewModel = ChangeUserInfoVM(networkUseCase: NetworkUsecase(network: Network()), isSignup: true)
    }
}

// MARK: Configure delegate
extension LoginSignupVC {
    private func configureTableViewDelegate() {
        self.majorCollectionView.dataSource = self
        self.majorCollectionView.delegate = self
        self.majorDetailCollectionView.dataSource = self
        self.majorDetailCollectionView.delegate = self
    }
    private func configureTextFieldDelegate() {
        self.phonenumTextField.delegate = self
        self.authNumTextField.delegate = self
    }
}

// MARK: Configure Menus
extension LoginSignupVC {
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
        let graduationMenuItems: [UIAction] = ["재학", "졸업"].map { status in
            return UIAction(title: status, image: nil) { [weak self] _ in
                self?.viewModel?.graduationStatus = status
            }
        }
        self.graduationStatusSelector.menu = UIMenu(title: "대학 / 졸업 선택", options: [], children: graduationMenuItems)
        self.graduationStatusSelector.showsMenuAsPrimaryAction = true
    }
}

// MARK: Bind
extension LoginSignupVC {
    private func bindAll() {
        self.bindMajor()
        self.bindMajorDetail()
        self.bindAlert()
        self.bindPhoneAuth()
        self.bindChangeNicknameStatus()
    }
    private func bindMajor() {
        self.viewModel?.$majors
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.majorCollectionView.reloadData()
            }
            .store(in: &self.cancellables)
    }
    private func bindMajorDetail() {
        self.viewModel?.$majorDetails
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.majorDetailCollectionView.reloadData()
            }
            .store(in: &self.cancellables)
    }
    private func bindAlert() {
        self.viewModel?.$alertStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                switch status {
                case .withoutPopVC(let message):
                    self?.showAlertWithOK(title: message.rawValue, text: "")
                case .withPopVC(let message):
                    self?.showAlertWithOK(title: message.rawValue, text: "") {
                        self?.navigationController?.popViewController(animated: true)
                    }
                case .none:
                    break
                }
            }
            .store(in: &self.cancellables)
    }
    private func bindPhoneAuth() {
        self.viewModel?.$phoneAuthStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                switch status {
                case .authComplete:
                    self?.configureUIForAuthComplete()
                case .authNumSent:
                    self?.configureUIForAuthSent()
                case .cancel:
                    self?.configureUIForAuthCanceled()
                case .wrongAuthNumber:
                    self?.coloredFrameLabels[2].configure(type: .warning("잘못된 인증 번호입니다."))
                case .invaildPhoneNum:
                    self?.coloredFrameLabels[1].configure(type: .warning("올바른 전화번호를 입력해주세요."))
                case .none:
                    break
                }
            }
            .store(in: &self.cancellables)
    }
    private func bindChangeNicknameStatus() {
        self.viewModel?.$changeNicknameStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                switch status {
                case .success:
                    self?.nickname.resignFirstResponder()
                    self?.coloredFrameLabels[0].configure(type: .success("사용가능한 닉네임입니다."))
                case .fail:
                    self?.coloredFrameLabels[0].configure(type: .warning("사용할 수 없는 닉네임입니다."))
                case .none:
                    break
                }
            }
            .store(in: &self.cancellables)
    }
}

extension LoginSignupVC {
    private func configureUIForAuthComplete() {
        self.getAuthNumButton.isHidden = true
        self.requestAgainButton.isHidden = true
        self.verifyAuthNumButton.isHidden = true
        
        self.authNumTextField.isEnabled = false
        
        self.coloredFrameLabels[1].isHidden = true
        self.coloredFrameLabels[2].configure(type: .success("인증이 완료되었습니다."))
    }
    private func configureUIForAuthSent() {
        self.getAuthNumButton.isHidden = true
        self.requestAgainButton.isHidden = false
        self.verifyAuthNumButton.isHidden = false
        
        self.authNumTextField.isEnabled = true
        self.authNumTextField.text = ""
        
        self.coloredFrameLabels[1].isHidden = true
        self.coloredFrameLabels[2].isHidden = true
        
        let buttonWidth = self.getAuthNumButton.frame.width
        self.phoneNumTextFieldTrailingConstraint.constant = -(buttonWidth + 10)
        
        self.showAlertWithOK(title: "인증번호가 전송되었습니다.", text: "")
    }
    private func configureUIForAuthCanceled() {
        self.getAuthNumButton.isHidden = false
        self.requestAgainButton.isHidden = true
        self.verifyAuthNumButton.isHidden = true
        
        self.authNumTextField.isEnabled = false
        self.authNumTextField.text = ""
        
        self.coloredFrameLabels[1].isHidden = true
        self.coloredFrameLabels[2].isHidden = true
        
        self.phoneNumTextFieldTrailingConstraint.constant = self.phoneNumTextFieldTrailingMargin
    }
}

// MARK: UICollectionView
extension LoginSignupVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == majorCollectionView {
            self.viewModel?.selectMajor(at: indexPath.item)
        } else {
            self.viewModel?.selectMajorDetail(at: indexPath.item)
        }
        collectionView.reloadData()
    }
}

extension LoginSignupVC: UICollectionViewDataSource {
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
            if majorName == self.viewModel?.selectedMajor {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init())
            }
            cell.configureText(major: majorName)
            return cell
        } else {
            guard let majorDetailName = self.viewModel?.majorDetails[indexPath.item] else { return cell }
            if majorDetailName == self.viewModel?.selectedMajorDetail {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init())
            }
            cell.configureText(major: majorDetailName)
            return cell
        }
    }
}

extension LoginSignupVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView == majorCollectionView ? CGSize(133, 39) : CGSize(68, 39)
    }
}

// MARK: 학교 팝업 관련
extension LoginSignupVC: SchoolSelectAction {
    func schoolSelected(_ name: String) {
        self.dismissKeyboard()
        self.viewModel?.schoolName = name
        self.schoolFinder.setTitle(name, for: .normal)
        self.schoolSearchView?.dismiss(animated: true, completion: nil)
    }
}

extension LoginSignupVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard self.checkIfTextChangeAvailable(textField) else { return false }
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return self.checkIfTextChangeAvailable(textField)
    }
    private func checkIfTextChangeAvailable(_ textField: UITextField) -> Bool {
        guard textField == phonenumTextField else { return true }
        switch self.viewModel?.phoneAuthStatus {
        case .authComplete:
            self.showAlertWithCancelAndOK(title: "인증 완료됨", text: "인증 완료된 전화번호를 바꾸시겠습니까?") { [weak self] in
                self?.viewModel?.cancelPhoneAuth()
            }
            return false
        case .authNumSent:
            self.showAlertWithCancelAndOK(title: "인증 진행중", text: "진행중인 인증을 취소하시겠습니까?") { [weak self] in
                self?.viewModel?.cancelPhoneAuth()
            }
            return false
        default:
            break
        }
        return true
    }
}
