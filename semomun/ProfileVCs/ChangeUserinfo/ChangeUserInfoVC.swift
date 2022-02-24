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
    @IBOutlet weak var phoneNumTF: UITextField!
    @IBOutlet weak var changePhoneNumButton: UIButton!
    
    @IBOutlet weak var additionalPhoneNumFrame: UIView!
    @IBOutlet weak var additionalTF: UITextField!
    @IBOutlet weak var authPhoneNumButton: UIButton!
    @IBOutlet weak var requestAgainButton: UIButton!
    
    @IBOutlet weak var majorCollectionView: UICollectionView!
    @IBOutlet weak var majorDetailCollectionView: UICollectionView!
    
    @IBOutlet weak var schoolFinder: UIButton!
    @IBOutlet weak var graduationStatusSelector: UIButton!
    
    @IBOutlet weak var additionalTextFieldTrailingConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureDelegate()
        self.bindAll()
        self.configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func checkNickname(_ sender: Any) {
        guard let nickname = self.nickname.text else { return }
        self.viewModel?.changeNicknameIfAvailable(nickname: nickname)
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
            guard let authNum = self.additionalTF.text else { return }
            self.viewModel?.confirmAuthNumber(with: authNum)
        } else {
            //인증요청
            guard let newPhoneStr = self.additionalTF.text else { return }
            self.viewModel?.requestPhoneAuth(withPhoneNumber: newPhoneStr)
        }
    }
    
    @IBAction func requestAuthAgain(_ sender: Any) {
        self.viewModel?.requestPhoneAuthAgain()
    }
    
    @IBAction func submit(_ sender: Any) {
        self.viewModel?.submitUserInfo()
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
        self.navigationItem.title = "계정 정보 변경하기"
        self.navigationItem.titleView?.backgroundColor = .white
        self.configureButtonMenus()
        self.additionalPhoneNumFrame.isHidden = true
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
        self.changePhoneNumButton.setTitle("취소", for: .normal)
        self.additionalPhoneNumFrame.isHidden = false
        self.additionalTF.placeholder = "변경할 전화번호를 입력해주세요."
        self.additionalTF.becomeFirstResponder()
        self.additionalTF.text = nil
        self.requestAgainButton.isHidden = true
        self.additionalTextFieldTrailingConstraint.constant = 12
    }
    private func prepareToHidePhoneNumFrame() {
        self.viewModel?.cancelPhoneAuth()
        self.changePhoneNumButton.setTitle("변경", for: .normal)
        self.additionalPhoneNumFrame.isHidden = true
        self.additionalTF.resignFirstResponder()
        self.coloredFrameLabels[1].isHidden = true
    }
}

// MARK: Configure ColoredFrameLabel
extension ChangeUserInfoVC {
    private func configureColoredFrameLabels() {
        self.coloredFrameLabels = (0..<2).map { _ in ColoredFrameLabel() }
        self.coloredFrameLabels.forEach { $0.isHidden = true }
        self.addFrameLabel(self.coloredFrameLabels[0], to: self.nicknameFrame)
        self.addFrameLabel(self.coloredFrameLabels[1], to: self.additionalPhoneNumFrame)
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
        self.additionalTF.delegate = self
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
                self?.viewModel?.graduationStatus = description
            }
        }
        self.graduationStatusSelector.menu = UIMenu(title: "대학 / 졸업 선택", options: [], children: graduationMenuItems)
        self.graduationStatusSelector.showsMenuAsPrimaryAction = true
    }
}

// MARK: Bind
extension ChangeUserInfoVC {
    private func bindAll() {
        self.bindNickname()
        self.bindMajor()
        self.bindMajorDetail()
        self.bindPhoneNum()
        self.bindSchoolName()
        self.bindGraduationStatus()
        self.bindAlert()
        self.bindPhoneAuth()
        self.bindConfigureUIForNicknamePhoneRequest()
        self.bindChangeNicknameStatus()
    }
    
    private func bindNickname() {
        self.viewModel?.$nickname
            .receive(on: DispatchQueue.main)
            .sink { [weak self] nickname in
                self?.nickname.text = nickname
            }
            .store(in: &self.cancellables)
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
    private func bindSchoolName() {
        self.viewModel?.$schoolName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] schoolName in
                self?.schoolFinder.setTitle(schoolName, for: .normal)
            }
            .store(in: &self.cancellables)
    }
    private func bindGraduationStatus() {
        self.viewModel?.$graduationStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.graduationStatusSelector.setTitle(status, for: .normal)
            }
            .store(in: &self.cancellables)
    }
    private func bindPhoneNum() {
        self.viewModel?.$phonenum
            .receive(on: DispatchQueue.main)
            .sink { [weak self] phone in
                self?.phoneNumTF.placeholder = phone
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
                    self?.isAuthPhoneTFShown = false
                    guard let button = self?.changePhoneNumButton else { break }
                    self?.configureButtonUI(button: button, isFilled: false)
                    button.setTitle("인증완료", for: .normal)
                    button.isEnabled = false
                    self?.showAlertWithOK(title: "인증이 완료되었습니다", text: "")
                case .authNumSent:
                    self?.showAlertWithOK(title: "인증번호가 전송되었습니다", text: "")
                    self?.coloredFrameLabels[1].isHidden = true
                    self?.changeAdditionalTFForAuthNum()
                case .none:
                    self?.authPhoneNumButton.setTitle("인증요청", for: .normal)
                    guard let button = self?.authPhoneNumButton else { break }
                    self?.configureButtonUI(button: button, isFilled: true)
                case .wrongAuthNumber:
                    self?.coloredFrameLabels[1].configure(type: .warning("잘못된 인증번호입니다"))
                case .invaildPhoneNum:
                    self?.coloredFrameLabels[1].configure(type: .warning("잘못된 전화번호입니다"))
                }
            }
            .store(in: &self.cancellables)
    }
    private func bindConfigureUIForNicknamePhoneRequest() {
        self.viewModel?.$configureUIForNicknamePhoneRequest
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard status else { return }
                self?.phoneNumTF.placeholder = "전화번호 정보 없음"
            }
            .store(in: &self.cancellables)
    }
    private func bindChangeNicknameStatus() {
        self.viewModel?.$changeNicknameStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let status = status else { return }
                if status == .success {
                    self?.nickname.resignFirstResponder()
                    self?.coloredFrameLabels[0].configure(type: .success("사용가능한 닉네임입니다."))
                } else {
                    self?.coloredFrameLabels[0].configure(type: .warning("사용할 수 없는 닉네임입니다."))
                }
            }
            .store(in: &self.cancellables)
    }
    private func changeAdditionalTFForAuthNum() {
        self.requestAgainButton.isHidden = false
        self.additionalTextFieldTrailingConstraint.constant = 12 + self.requestAgainButton.frame.width
        self.authPhoneNumButton.setTitle("인증확인", for: .normal)
        self.additionalTF.text = nil
        self.additionalTF.placeholder = "인증번호를 입력해주세요."
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

extension ChangeUserInfoVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView == majorCollectionView ? CGSize(133, 39) : CGSize(68, 39)
    }
}

// MARK: 학교 팝업 Delegate
extension ChangeUserInfoVC: SchoolSelectAction {
    func schoolSelected(_ name: String) {
        self.dismissKeyboard()
        self.viewModel?.schoolName = name
        self.schoolFinder.setTitle(name, for: .normal)
        self.schoolSearchView?.dismiss(animated: true, completion: nil)
    }
}

extension ChangeUserInfoVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
}
