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
    var signUpInfo: SignUpInfo?
    
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
            
//            let SignUpInfo = SignUpInfo_DB(name: signUpInfo?.name ?? "", phoneNumber: signUpInfo!.phoneNumber ?? "", desiredCategory: signUpInfo?.desiredCategory ?? [""], field: signUpInfo?.field ?? "", interest: signUpInfo?.interest ?? [], gender: signUpInfo?.gender ?? "", birthday: signUpInfo?.birthday ?? "", schoolName: signUpInfo?.schoolName ?? "", graduationStatus: signUpInfo?.graduationStatus ?? "")
//            let jsonEncoder = JSONEncoder()
//            let jsonData_signUpInfo = try! jsonEncoder.encode(SignUpInfo)
//            let jsonData_token = try! jsonEncoder.encode(signUpInfo?.token)
//            let json_signUpInfo = String(data: jsonData_signUpInfo, encoding: String.Encoding.utf8)
//            let json_token = String(data: jsonData_token, encoding: String.Encoding.utf8)
//            let json: [String: Any] = ["info" : json_signUpInfo!,
//                                       "token": json_token!]
//
//            let jsonData = try? JSONSerialization.data(withJSONObject: json)
//            print(json)
//            print(jsonData)

            // Backend 확인 이후 로직
            UserDefaults.standard.setValue(true, forKey: "logined")
            self.goMainVC()
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
