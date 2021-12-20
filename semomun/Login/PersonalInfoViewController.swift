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
    @IBOutlet weak var school: UIButton!
    @IBOutlet weak var graduation: UIButton!
    private var infoFilled: Bool = false
    private var datePicker: UIDatePicker?
    private var graduationMenu: UIMenu?
    var signUpInfo: SignUpInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        self.configureDatePicker()
        self.configureTextField()
        self.configureGraduationMenuItems()
        self.configureGraduation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "회원가입"
    }
    
    
    @IBAction func tapSchool(_ sender: Any) {
    }
    
    @IBAction func completeSignup(_ sender: Any) {
        infoFilled = true
        if(infoFilled) {
//            guard let name = self.name.text,
//                  let phoneNumber = self.phone.text else { return }

//            self.signUpInfo.configureSecond(desiredCategory: [], field: "", interest: [])
            self.signUpInfo?.configureThird(birthdayYear: "2021", birthdayMonth: "11", birthdayDay: "11", schoolName: "Sky", graduationStatus: "Yes")
            let SignUpInfo = SignUpInfo_DB(name: signUpInfo?.name ?? "", phoneNumber: signUpInfo!.phoneNumber ?? "", desiredCategory: signUpInfo?.desiredCategory ?? [""], field: signUpInfo?.field ?? "", interest: signUpInfo?.interest ?? [], gender: signUpInfo?.gender ?? "", birthday: signUpInfo?.birthday ?? "", schoolName: signUpInfo?.schoolName ?? "", graduationStatus: signUpInfo?.graduationStatus ?? "")
            let jsonEncoder = JSONEncoder()
            let jsonData_signUpInfo = try! jsonEncoder.encode(SignUpInfo)
            let jsonData_token = try! jsonEncoder.encode(signUpInfo?.token)
            let json_signUpInfo = String(data: jsonData_signUpInfo, encoding: String.Encoding.utf8)
            let json_token = String(data: jsonData_token, encoding: String.Encoding.utf8)
            let json: [String: Any] = ["info" : json_signUpInfo!,
                                       "token": json_token!]
            
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            print(json)
            print(jsonData)

            // Backend 확인 이후 로직
            UserDefaults.standard.setValue(true, forKey: "logined")
            self.goMainVC()
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
    
    private func configureTextField() {
        self.dateOfBorn.inputView = self.datePicker
    }
    
    @objc func dateChanged() {
        guard let date = self.datePicker?.date else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        self.dateOfBorn.text = dateFormatter.string(from: date)
    }
    
    private func configureGraduationMenuItems() {
        var menuItems: [UIAction] = []
        menuItems.append(UIAction(title: "재학", image: nil, handler: { [weak self] _ in
            self?.graduation.setTitle("재학", for: .normal)
            self?.graduation.setTitleColor(.black, for: .normal)
            self?.signUpInfo?.configureGraduation(to: "재학")
        }))
        menuItems.append(UIAction(title: "졸업", image: nil, handler: { [weak self] _ in
            self?.graduation.setTitle("졸업", for: .normal)
            self?.graduation.setTitleColor(.black, for: .normal)
            self?.signUpInfo?.configureGraduation(to: "졸업")
        }))
        self.graduationMenu = UIMenu(title: "재학/졸업 여부", image: nil, identifier: nil, options: [], children: menuItems)
    }
    
    private func configureGraduation() {
        self.graduation.menu = self.graduationMenu
        self.graduation.showsMenuAsPrimaryAction = true
    }
}
