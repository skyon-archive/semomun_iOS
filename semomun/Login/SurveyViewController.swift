//
//  SurveyViewController.swift
//  semomun
//
//  Created by Kang Minsang on 2021/11/21.
//

import UIKit
import SwiftUI

class SurveyViewController: UIViewController {
    static let identifier = "SurveyViewController"
    enum NotificationName {
        static let selectMajor = Notification.Name.init(rawValue: "selectMajor")
    }
    enum NotificationUserInfo {
        static let sectionKey = "sectionKey"
    }
    @IBOutlet weak var majorDetailTitle: UILabel!
    @IBOutlet weak var majorDetailView: UIView!
    @IBOutlet weak var schoolFrame: UIView!
    @IBOutlet weak var school: UIButton!
    @IBOutlet weak var graduation: UIButton!
    private var majorViewController: MajorViewController?
    private var majorDetailViewController: MajorDetailViewController?
    private var schoolMenu: UIMenu?
    private var graduationMenu: UIMenu?
    private var schoolSearchView: UIHostingController<LoginSchoolSearchView>?
    var signUpInfo: UserInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.configureMajorDetailView()
        self.configureMajors()
        self.configureSchoolMenuItems()
        self.configureGraduationMenuItems()
        self.configureSchool()
        self.configureGraduation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "회원가입"
    }
    
    @IBAction func nextVC(_ sender: Any) {
        guard let signUpInfo = signUpInfo else { return }
        // gender, birthday configure
        signUpInfo.configureGender(to: "none")
        signUpInfo.configureBirthday(to: "none")
        
        if signUpInfo.isValidSurvay {
            self.nextVC()
        } else {
            self.showAlertWithOK(title: "정보가 부족합니다", text: "정보를 모두 기입해주시기 바랍니다.")
        }
    }
    
    private func didSelect(to button: UIButton) {
        button.borderColor = UIColor.clear
        button.backgroundColor = UIColor(named: SemomunColor.mainColor)
        button.setTitleColor(UIColor.white, for: .normal)
    }
    
    private func diSelect(from button: UIButton) {
        button.borderColor = UIColor.black
        button.backgroundColor = UIColor.white
        button.setTitleColor(UIColor.black, for: .normal)
    }
}

//MARK: - Configure
extension SurveyViewController {
    private func configureUI() {
        self.school.clipsToBounds = true
        self.school.layer.cornerRadius = 8
        self.graduation.clipsToBounds = true
        self.graduation.layer.cornerRadius = 8
    }
    
    private func configureMajorDetailView() {
        self.majorDetailTitle.alpha = 0
        self.majorDetailView.alpha = 0
        self.schoolFrame.transform = CGAffineTransform.init(translationX: 0, y: -160)
    }
    
    private func configureMajors() {
        let network = Network()
        let networkUseCase = NetworkUsecase(network: network)
        networkUseCase.getMajors { [weak self] majors in
            guard let majors = majors else {
                self?.showAlertWithOK(title: "네트워크 오류", text: "다시 시도하시기 바랍니다.")
                return
            }
            self?.majorViewController?.updateMajors(with: majors)
            self?.majorDetailViewController?.updateMajors(with: majors)
        }
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
    
    private func configureSchool() {
        self.school.menu = self.schoolMenu
        self.school.showsMenuAsPrimaryAction = true
    }
    
    private func configureGraduation() {
        self.graduation.menu = self.graduationMenu
        self.graduation.showsMenuAsPrimaryAction = true
    }
}

//MARK: - Connection CollectionViews
extension SurveyViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case MajorViewController.Identifier.segue:
            guard let destination = segue.destination as? MajorViewController else { return }
            self.majorViewController = destination
            destination.delegate = self
        case MajorDetailViewController.Identifier.segue:
            guard let destination = segue.destination as? MajorDetailViewController else { return }
            self.majorDetailViewController = destination
            destination.delegate = self
        default: return
        }
    }
}

extension SurveyViewController: MajorSetable {
    func didSelectMajor(section index: Int, to major: String) {
        self.acticationMajorDetail(section: index)
        self.signUpInfo?.configureMajor(to: major)
        self.signUpInfo?.configureMajorDetail(to: nil)
    }
}
extension SurveyViewController: MajorDetailSetable {
    func didSelectMajorDetail(to majorDetail: String) {
        self.signUpInfo?.configureMajorDetail(to: majorDetail)
    }
}

extension SurveyViewController: SchoolSelectAction {
    func schoolSelected(_ name: String) {
        self.signUpInfo?.configureSchool(to: name)
        self.school.setTitle(name, for: .normal)
        self.school.setTitleColor(.black, for: .normal)
        self.dismissKeyboard()
        self.schoolSearchView?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Logic
extension SurveyViewController {
    private func updateGraduation(to state: String) {
        self.graduation.setTitle(state, for: .normal)
        self.graduation.setTitleColor(.black, for: .normal)
        self.signUpInfo?.configureGraduation(to: state)
        self.dismissKeyboard()
    }
    
    private func acticationMajorDetail(section index: Int) {
        NotificationCenter.default.post(name: NotificationName.selectMajor, object: nil, userInfo: [NotificationUserInfo.sectionKey: index])
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.majorDetailTitle.alpha = 1
            self?.majorDetailView.alpha = 1
            self?.schoolFrame.transform = CGAffineTransform.identity
        }
    }
    
    private func nextVC() {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: LoginViewController.identifier) as? LoginViewController else { return }
        nextVC.signupInfo = self.signUpInfo
        
        self.title = ""
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}
