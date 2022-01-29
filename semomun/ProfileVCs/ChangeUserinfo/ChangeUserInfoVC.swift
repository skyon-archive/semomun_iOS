//
//  ChangeUserinfoPopupVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import SwiftUI
import Combine

class ChangeUserInfoVC: UIViewController {

    static let storyboardName = "Profile"
    static let identifier = "ChangeUserInfoVC"
    
    private let viewModel = ChangeUserInfoVM(networkUseCase: NetworkUsecase(network: Network()))
    private var schoolSearchView: UIHostingController<LoginSchoolSearchView>?
    private var cancellables: Set<AnyCancellable> = []
    
    private var isAuthPhoneTFShown = false {
        didSet {
            if self.isAuthPhoneTFShown {
                self.changePhoneNumButton.setTitle("취소", for: .normal)
                self.additionalPhoneNumFrame.isHidden = false
                self.additionalTF.placeholder = "변경할 전화번호를 입력해주세요."
                self.additionalTF.becomeFirstResponder()
                self.additionalTF.text = nil
                self.requestAgainButton.isHidden = true
            } else {
                self.viewModel.cancelPhoneAuth()
                self.changePhoneNumButton.setTitle("변경", for: .normal)
                self.additionalPhoneNumFrame.isHidden = true
                self.additionalTF.resignFirstResponder()
            }
            UIView.animate(withDuration: 0.25) { [weak self] in
                self?.view.layoutIfNeeded()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.configureTableViewDelegate()
        self.bindAll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    @IBAction func checkNickname(_ sender: Any) {
        guard let nickname = self.nickname.text else {
            self.showAlertWithOK(title: "닉네임을 입력하세요", text: "")
            return
        }
        self.viewModel.changeNicknameIfAvailable(nickname: nickname) { isSuccess in
            if isSuccess {
                self.nickname.resignFirstResponder()
                self.showAlertWithOK(title: "사용할 수 있는 닉네임입니다.", text: "")
            } else {
                self.showAlertWithOK(title: "중복된 닉네임입니다.", text: "")
            }
        }
    }
    
    @IBAction func changePhoneNum(_ sender: Any) {
        self.isAuthPhoneTFShown.toggle()
    }
    
    @IBAction func requestOrConfirmAuth(_ sender: UIButton) {
        if sender.titleLabel?.text == "인증확인" {
            //인증확인
            guard let authStr = self.additionalTF.text, let authNum = Int(authStr) else {
                self.showAlertWithOK(title: "인증번호를 입력하세요", text: "")
                return
            }
            self.viewModel.confirmAuthNumber(with: authNum)
        } else {
            //인증요청
            guard let newPhoneStr = self.additionalTF.text else { return }
            self.viewModel.requestPhoneAuth(withPhoneNumber: newPhoneStr)
        }
    }
    
    @IBAction func requestAuthAgain(_ sender: Any) {
        self.viewModel.requestPhoneAuthAgain()
    }
    
    @IBAction func submit(_ sender: Any) {
        self.viewModel.submitUserInfo()
    }
}

// MARK: Configure UI
extension ChangeUserInfoVC {
    private func configureUI() {
        self.navigationItem.title = "계정 정보 변경하기"
        self.configureBodyFrameUI()
        self.configureRoundedMintBorder(of: nicknameFrame)
        self.configureRoundedMintBorder(of: phoneNumFrame)
        self.configureRoundedMintBorder(of: additionalPhoneNumFrame)
        self.configureButtonMenus()
        self.additionalPhoneNumFrame.isHidden = true
        self.requestAgainButton.isHidden = true
    }
    private func configureBodyFrameUI() {
        self.bodyFrame.layer.cornerRadius = 15
        self.bodyFrame.addShadow(direction: .top)
    }
    private func configureRoundedMintBorder(of view: UIView) {
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor(named: "mainColor")?.cgColor
        view.layer.cornerRadius = 5
    }
    private func configureButtonUI(button: UIButton, isFilled: Bool) {
        guard let mainColor = UIColor(named: "mainColor") else { return }
        if isFilled {
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = mainColor
            button.borderColor = .white
        } else {
            button.setTitleColor(mainColor, for: .normal)
            button.backgroundColor = .white
            button.borderColor = mainColor
        }
    }
}

// MARK: Configure delegate
extension ChangeUserInfoVC {
    private func configureTableViewDelegate() {
        self.majorCollectionView.dataSource = self
        self.majorCollectionView.delegate = self
        self.majorDetailCollectionView.dataSource = self
        self.majorDetailCollectionView.delegate = self
    }
}

// MARK: Configure Menus
extension ChangeUserInfoVC {
    enum GraduationStatus: String, CaseIterable {
        case attending = "재학"
        case graduated = "졸업"
    }
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
        let graduationMenuItems: [UIAction] = GraduationStatus.allCases.map { status in
            let description = status.rawValue
            return UIAction(title: description, image: nil) { [weak self] _ in
                self?.viewModel.graduationStatus = description
                self?.graduationStatusSelector.setTitle(description, for: .normal)
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
    }
    private func bindNickname() {
        self.viewModel.$nickname
            .receive(on: DispatchQueue.main)
            .sink { [weak self] nickname in
                self?.nickname.text = nickname
            }
            .store(in: &self.cancellables)
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
    private func bindSchoolName() {
        self.viewModel.$schoolName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] schoolName in
                self?.schoolFinder.setTitle(schoolName, for: .normal)
            }
            .store(in: &self.cancellables)
    }
    private func bindGraduationStatus() {
        self.viewModel.$graduationStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.graduationStatusSelector.setTitle(status, for: .normal)
            }
            .store(in: &self.cancellables)
    }
    private func bindPhoneNum() {
        self.viewModel.$phonenum
            .receive(on: DispatchQueue.main)
            .sink { [weak self] phone in
                self?.phoneNumTF.placeholder = phone
            }
            .store(in: &self.cancellables)
    }
    private func bindAlert() {
        self.viewModel.$alertStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                var alertMessage: String?
                switch status {
                case .incompleteData:
                    alertMessage = "정보가 모두 입력되지 않았습니다"
                case .networkError:
                    alertMessage = "네트워크가 연결되어있지 않습니다"
                case .coreDataFetchError:
                    alertMessage = "일시적인 문제가 발생했습니다"
                case .saveSuccess:
                    self?.showAlertWithOK(title: "저장이 완료되었습니다", text: "") {
                        self?.navigationController?.popViewController(animated: true)
                    }
                case .majorDetailNotSelected:
                    alertMessage = "전공을 선택해주세요"
                case .none:
                    break
                }
                if let alertMessage = alertMessage {
                    self?.showAlertWithOK(title: alertMessage, text: "")
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
                    self?.isAuthPhoneTFShown = false
                    guard let button = self?.changePhoneNumButton else { break }
                    self?.configureButtonUI(button: button, isFilled: false)
                    button.setTitle("인증완료", for: .normal)
                    button.isEnabled = false
                    self?.showAlertWithOK(title: "인증 완료", text: "")
                case .authNumSent:
                    self?.showAlertWithOK(title: "인증번호 전송됨", text: "")
                    self?.changeAdditionalTFForAuthNum()
                case .none:
                    self?.authPhoneNumButton.setTitle("인증요청", for: .normal)
                    guard let button = self?.authPhoneNumButton else { break }
                    self?.configureButtonUI(button: button, isFilled: true)
                case .wrongAuthNumber:
                    self?.showAlertWithOK(title: "잘못된 인증 번호", text: "")
                case .invaildPhoneNum:
                    self?.showAlertWithOK(title: "잘못된 전화번호", text: "")
                }
            }
            .store(in: &self.cancellables)
    }
    private func changeAdditionalTFForAuthNum() {
        self.requestAgainButton.isHidden = false
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
            self.viewModel.selectMajor(at: indexPath.item)
        } else {
            self.viewModel.selectMajorDetail(at: indexPath.item)
        }
        collectionView.reloadData()
    }
}

extension ChangeUserInfoVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == majorCollectionView ? self.viewModel.majors?.count ?? 0 : self.viewModel.majorDetails?.count ?? 0
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

extension ChangeUserInfoVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView == majorCollectionView ? CGSize(133, 39) : CGSize(68, 39)
    }
}

// MARK: 학교 팝업 관련
extension ChangeUserInfoVC: SchoolSelectAction {
    func schoolSelected(_ name: String) {
        self.dismissKeyboard()
        self.viewModel.schoolName = name
        self.schoolFinder.setTitle(name, for: .normal)
        self.schoolSearchView?.dismiss(animated: true, completion: nil)
    }
}
