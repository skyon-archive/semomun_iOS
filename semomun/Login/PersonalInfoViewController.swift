//
//  PersonalInfoViewController.swift
//  semomun
//
//  Created by Kang Minsang on 2021/11/21.
//

import UIKit

class PersonalInfoViewController: UIViewController {
    static let identifier = "PersonalInfoViewController"

    @IBOutlet weak var dateOfBorn: UITextField!
    @IBOutlet weak var schoolTextField: UITextField!
    @IBOutlet weak var searchSchoolButton: UIButton!
    @IBOutlet weak var graduation: UIButton!
    private var states: [Bool] = [false, false, false]
    private var datePicker: UIDatePicker?
    private var graduationMenu: UIMenu?
    var signUpInfo: UserInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        self.configureDatePicker()
        self.configureBornTextField()
        self.configureSchoolTextField()
        self.configureGraduationMenuItems()
        self.configureGraduation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "회원가입"
    }
    
    @IBAction func schoolInputChanged(_ sender: UITextField) {
        guard let input = sender.text else { return }
        self.searchSchool(to: input)
    }
    
    @IBAction func searchSchool(_ sender: Any) {
        self.dismissKeyboard()
        guard let input = self.schoolTextField.text else { return }
        self.searchSchool(to: input)
    }
    
    @IBAction func completeSignup(_ sender: Any) {
        if self.isValidForSignUp {
            self.signUpInfo?.configureNickname()
            self.configureSignupInfo()
        } else {
            self.showAlertWithOK(title: "정보가 부족합니다", text: "정보를 모두 기입해주시기 바랍니다.")
        }
    }
}

extension PersonalInfoViewController {
    private func goMainVC() {
        guard let mainViewController = self.storyboard?.instantiateViewController(identifier: MainViewController.identifier) else { return }
        let navigationController = UINavigationController(rootViewController: mainViewController)
        navigationController.navigationBar.tintColor = UIColor(named: "mint")
        
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    
    private func configureDatePicker() {
        self.datePicker = UIDatePicker()
        self.datePicker?.datePickerMode = .date
        self.datePicker?.preferredDatePickerStyle = .wheels
        self.datePicker?.locale = NSLocale(localeIdentifier: "ko_KO") as Locale
        self.datePicker?.addTarget(self, action: #selector(dateChanged), for: .allEvents)
    }
    
    private func configureBornTextField() {
        self.dateOfBorn.inputView = self.datePicker
    }
    
    @objc func dateChanged() {
        guard let date = self.datePicker?.date else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let birthday = dateFormatter.string(from: date)
        self.dateOfBorn.text = birthday
        self.signUpInfo?.configureBirthday(to: birthday)
        self.states[0] = true
    }
    
    private func configureGraduationMenuItems() {
        var menuItems: [UIAction] = []
        menuItems.append(UIAction(title: "재학", image: nil, handler: { [weak self] _ in
            self?.graduation.setTitle("재학", for: .normal)
            self?.graduation.setTitleColor(.black, for: .normal)
            self?.signUpInfo?.configureGraduation(to: "재학")
            self?.states[2] = true
        }))
        menuItems.append(UIAction(title: "졸업", image: nil, handler: { [weak self] _ in
            self?.graduation.setTitle("졸업", for: .normal)
            self?.graduation.setTitleColor(.black, for: .normal)
            self?.signUpInfo?.configureGraduation(to: "졸업")
            self?.states[2] = true
        }))
        self.graduationMenu = UIMenu(title: "재학/졸업 여부", image: nil, identifier: nil, options: [], children: menuItems)
    }
    
    private func configureGraduation() {
        self.graduation.menu = self.graduationMenu
        self.graduation.showsMenuAsPrimaryAction = true
    }
    
    private func searchSchool(to school: String) {
        print("search: \(school)") //TODO: 검색 어떻게 할지 의논 필요
        
        self.schoolTextField.textColor = .black
        self.signUpInfo?.configureSchool(to: school)
        self.states[1] = true
    }
    
    private var isValidForSignUp: Bool {
        return self.states[0] && self.states[1] && self.states[2]
    }
    
    private func configureSignupInfo() {
        let jsonEncoder = JSONEncoder()
        guard let jsonData = try? jsonEncoder.encode(self.signUpInfo) else { return }
        guard let jsonStringData = String(data: jsonData, encoding: String.Encoding.utf8) else { return }
        let jsonSignupInfo: [String: String] = ["info" : jsonStringData,
                                             "token": KeychainItem.currentUserIdentifier]
        NetworkUsecase.postUserSignup(userInfo: jsonSignupInfo) { [weak self] success in
            guard let success = success else {
                print("nil data")
                return
            }
            if success {
                self?.showAlertOKWithClosure(title: "회원가입이 완료되었습니다.", text: "", completion: { [weak self] _ in
                    CoreUsecase.createUserCoreData(userInfo: self?.signUpInfo)
                    self?.configureUserDefaults()
                    self?.goMainVC()
                })
            } else {
                self?.showAlertWithOK(title: "회원가입 실패", text: "다시 시도해주시기 바랍니다.")
            }
        }
    }
    
    private func configureUserDefaults() {
        guard let currentCategory = self.signUpInfo?.favoriteCategory else { return }
        UserDefaults.standard.setValue(true, forKey: "logined")
        UserDefaults.standard.setValue(currentCategory, forKey: "currentCategory")
    }
}

extension PersonalInfoViewController: UITextFieldDelegate {
    private func configureSchoolTextField() {
        self.schoolTextField.delegate = self
        self.schoolTextField.addTarget(self, action: #selector(self.schoolChanged), for: .editingChanged)
    }
    
    @objc func schoolChanged() {
        self.schoolTextField.textColor = .lightGray
        self.states[1] = false
    }
}
