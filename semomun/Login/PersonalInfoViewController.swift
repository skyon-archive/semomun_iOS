//
//  PersonalInfoViewController.swift
//  semomun
//
//  Created by Kang Minsang on 2021/11/21.
//

import UIKit
import SwiftUI

class PersonalInfoViewController: UIViewController {
    static let identifier = "PersonalInfoViewController"

    @IBOutlet weak var dateOfBorn: UITextField!
    @IBOutlet weak var school: UIButton!
    @IBOutlet weak var graduation: UIButton!
    
    private var states: [Bool] = [false, false, false]
    private var datePicker: UIDatePicker?
    private var schoolMenu: UIMenu?
    private var graduationMenu: UIMenu?
    var signUpInfo: UserInfo?
    
    var schoolSearchView: UIHostingController<LoginSchoolSearchView>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        self.configureDatePicker()
        self.configureBornTextField()
        self.configureSchoolMenuItems()
        self.configureGraduationMenuItems()
        self.configureSchool()
        self.configureGraduation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "회원가입"
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

extension PersonalInfoViewController: SchoolSelectAction {
    func schoolSelected(_ name: String) {
        self.signUpInfo?.configureSchool(to: name)
        self.school.setTitle(name, for: .normal)
        self.school.setTitleColor(.black, for: .normal)
        self.dismissKeyboard()
        self.schoolSearchView?.dismiss(animated: true, completion: nil)
        self.states[1] = true
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
    
    private func configureSchoolMenuItems() {
        let menuItems: [UIAction] = SchoolSearchUseCase.SchoolType.allCases.map { schoolType in
            UIAction(title: schoolType.rawValue, image: nil, handler: { [weak self] _ in
                self?.schoolSearchView = UIHostingController(rootView: LoginSchoolSearchView(delegate: self, schoolType: schoolType))
                self?.schoolSearchView?.view.backgroundColor = .clear
                if let view = self?.schoolSearchView {
                    self?.present(view, animated: true, completion: nil)
                }
            })
        }
        self.schoolMenu = UIMenu(title: "학교 선택", image: nil, identifier: nil, options: [], children: menuItems)
    }
    
    private func configureGraduationMenuItems() {
        var menuItems: [UIAction] = []
        menuItems.append(UIAction(title: "재학", image: nil, handler: { [weak self] _ in
            self?.updateGraduation(to: "재학")
        }))
        menuItems.append(UIAction(title: "졸업", image: nil, handler: { [weak self] _ in
            self?.updateGraduation(to: "졸업")
        }))
        self.graduationMenu = UIMenu(title: "재학/졸업 여부", image: nil, identifier: nil, options: [], children: menuItems)
    }
    
    private func updateGraduation(to state: String) {
        self.graduation.setTitle(state, for: .normal)
        self.graduation.setTitleColor(.black, for: .normal)
        self.signUpInfo?.configureGraduation(to: state)
        self.dismissKeyboard()
        self.states[2] = true
    }
    
    private func configureSchool() {
        self.school.menu = self.schoolMenu
        self.school.showsMenuAsPrimaryAction = true
    }
    
    private func configureGraduation() {
        self.graduation.menu = self.graduationMenu
        self.graduation.showsMenuAsPrimaryAction = true
    }
    
    private func searchSchool(to school: String) {
        print("search: \(school)") //TODO: 검색 어떻게 할지 의논 필요
        
        self.signUpInfo?.configureSchool(to: school)
        self.states[1] = true
    }
    
    private var isValidForSignUp: Bool {
        return self.states.allSatisfy({$0})
    }
    
    private func configureSignupInfo() {
        guard let userInfo = self.signUpInfo else { return }
        NetworkUsecase.postUserSignup(userInfo: userInfo) { [weak self] success in
            guard let success = success else {
                print("nil data")
                return
            }
            if success {
                self?.showAlertOKWithClosure(title: "회원가입이 완료되었습니다", text: "", completion: { [weak self] _ in
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
        UserDefaults.standard.setValue(currentCategory, forKey: "currentCategory")
        UserDefaults.standard.setValue(true, forKey: "logined")
    }
}
