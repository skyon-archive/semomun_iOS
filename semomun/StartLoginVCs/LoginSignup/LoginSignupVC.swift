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
    
    private let viewModel = ChangeUserInfoVM(networkUseCase: NetworkUsecase(network: Network()), isSignup: true)
    private var schoolSearchView: UIHostingController<LoginSchoolSearchView>?
    private var cancellables: Set<AnyCancellable> = []
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.configureTableViewDelegate()
        self.configureTextFieldDelegate()
        self.bindAll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        UserDefaultsManager.set(to: "2.0", forKey: UserDefaultsManager.Keys.userVersion)
    }
    
    @IBAction func checkNickname(_ sender: Any) {
        guard let nickname = self.nickname.text, nickname != "" else {
            self.addColoredFrame(to: nicknameFrame, type: .warning("닉네임을 입력해주세요."))
            return
        }
        self.viewModel.changeNicknameIfAvailable(nickname: nickname) { [weak self] isSuccess in
            guard let nicknameFrame = self?.nicknameFrame else { return }
            if isSuccess {
                self?.nickname.resignFirstResponder()
                self?.addColoredFrame(to: nicknameFrame, type: .success("사용가능한 닉네임입니다."))
            } else {
                self?.addColoredFrame(to: nicknameFrame, type: .warning("사용할 수 없는 닉네임입니다."))
            }
        }
    }
    
    @IBAction func requestAuth(_ sender: Any) {
        guard let newPhoneStr = self.phonenumTextField.text else { return }
        self.viewModel.requestPhoneAuth(withPhoneNumber: newPhoneStr)
    }
    
    @IBAction func confirmAuth(_ sender: UIButton) {
        guard let authStr = self.authNumTextField.text, let authNum = Int(authStr) else {
            self.addColoredFrame(to: self.authNumFrame, type: .warning("인증번호를 입력해주세요."))
            return
        }
        self.viewModel.confirmAuthNumber(with: authNum)
    }
    
    @IBAction func requestAuthAgain(_ sender: Any) {
        self.viewModel.requestPhoneAuthAgain()
    }
    
    @IBAction func submit(_ sender: Any) {
        let userInfo = self.viewModel.makeUserInfo()
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
        let userInfo = self.viewModel.makeUserInfo()
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
    }
    private func configureButtonUI(button: UIButton, isFilled: Bool) {
        let mainColor = UIColor(.mainColor)
        if isFilled {
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = mainColor
        } else {
            button.setTitleColor(mainColor, for: .normal)
            button.backgroundColor = .white
        }
    }
}

// MARK: 성공/실패 메시지 관련 UI configure
extension LoginSignupVC {
    private func addColoredFrame(to frame: UIView, type: ColoredFrameLabel.Content) {
        switch type {
        case .success(let message):
            frame.borderColor = UIColor(.mainColor)
            let successView = ColoredFrameLabel(withMessage: message, type: type)
            successView.attach(to: frame)
        case .warning(let message):
            frame.borderColor = UIColor(.redColor)
            let warningView = ColoredFrameLabel(withMessage: message, type: type)
            warningView.attach(to: frame)
        }
    }
    private func removeColoredFrame(from frame: UIView) {
        frame.borderColor = UIColor(.mainColor)
        ColoredFrameLabel.remove(from: frame)
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
                self?.viewModel.graduationStatus = status
                self?.graduationStatusSelector.setTitle(status, for: .normal)
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
    }
    private func bindMajor() {
        self.viewModel.$majors
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.majorCollectionView.reloadData()
            }
            .store(in: &self.cancellables)
    }
    private func bindMajorDetail() {
        self.viewModel.$majorDetails
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.majorDetailCollectionView.reloadData()
            }
            .store(in: &self.cancellables)
    }
    private func bindAlert() {
        self.viewModel.$alertStatus
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
        self.viewModel.$phoneAuthStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                switch status {
                case .authComplete:
                    self?.configureUIForAuthComplete()
                case .authNumSent:
                    self?.configureUIForAuthSent()
                case .wrongAuthNumber:
                    if let additionalPhoneNumFrame = self?.authNumFrame {
                        self?.addColoredFrame(to: additionalPhoneNumFrame, type: .warning("잘못된 인증 번호입니다."))
                    }
                case .invaildPhoneNum:
                    if let phoneNumFrame = self?.phonenumFrame {
                        self?.addColoredFrame(to: phoneNumFrame, type: .warning("올바른 전화번호를 입력해주세요."))
                    }
                case .none:
                    break
                }
            }
            .store(in: &self.cancellables)
    }
}

extension LoginSignupVC {
    private func configureUIForAuthSent() {
        self.removeColoredFrame(from: self.phonenumFrame)
        self.showAlertWithOK(title: "인증번호가 전송되었습니다.", text: "")
        
        self.phonenumTextField.isEnabled = false
        self.authNumTextField.isEnabled = true
        
        self.getAuthNumButton.isHidden = true
        self.requestAgainButton.isHidden = false
        self.verifyAuthNumButton.isHidden = false
    }
    private func configureUIForAuthComplete() {
        self.requestAgainButton.isHidden = true
        self.verifyAuthNumButton.isHidden = true
        
        self.authNumTextField.isEnabled = false
        self.verifyAuthNumButton.isEnabled = false
        
        self.addColoredFrame(to: self.authNumFrame, type: .success("인증이 완료되었습니다."))
    }
}

// MARK: UICollectionView
extension LoginSignupVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == majorCollectionView {
            self.viewModel.selectMajor(at: indexPath.item)
        } else {
            self.viewModel.selectMajorDetail(at: indexPath.item)
        }
        collectionView.reloadData()
    }
}

extension LoginSignupVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == majorCollectionView {
            return self.viewModel.majors?.count ?? 0
        } else {
            return self.viewModel.majorDetails?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MajorCollectionViewCell.identifier, for: indexPath) as? MajorCollectionViewCell else { return UICollectionViewCell() }
        if collectionView == majorCollectionView {
            guard let majorName = self.viewModel.majors?[indexPath.item] else { return cell }
            if majorName == self.viewModel.selectedMajor {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init())
            }
            cell.configureText(major: majorName)
            return cell
        } else {
            guard let majorDetailName = self.viewModel.majorDetails?[indexPath.item] else { return cell }
            if majorDetailName == self.viewModel.selectedMajorDetail {
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
        self.viewModel.schoolName = name
        self.schoolFinder.setTitle(name, for: .normal)
        self.schoolSearchView?.dismiss(animated: true, completion: nil)
    }
}

extension LoginSignupVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
}
