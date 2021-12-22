//
//  SurveyViewController.swift
//  semomun
//
//  Created by Kang Minsang on 2021/11/21.
//

import UIKit

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
    @IBOutlet weak var genderFrame: UIView!
    @IBOutlet var genders: [UIButton]!
    var signUpInfo: UserInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureGengerUI()
        self.configureMajorDetailView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "회원가입"
    }
    
    @IBAction func selectGender(_ sender: UIButton) {
        guard let gender = sender.titleLabel?.text else { return }
        switch gender {
        case "남":
            self.didSelect(to: genders[0])
            self.diSelect(from: genders[1])
        case "여":
            self.didSelect(to: genders[1])
            self.diSelect(from: genders[0])
        default: return
        }
        self.signUpInfo?.configureGender(to: gender)
    }
    
    @IBAction func nextVC(_ sender: Any) {
        guard let signUpInfo = signUpInfo else { return }
        if signUpInfo.isValidSurvay {
            self.nextVC()
        } else {
            self.showAlertWithOK(title: "정보가 부족합니다", text: "정보를 모두 기입해주시기 바랍니다.")
        }
    }
    
    private func didSelect(to button: UIButton) {
        button.borderColor = UIColor.clear
        button.backgroundColor = UIColor(named: "mint")
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
    private func configureGengerUI() {
        genders.forEach { button in
            button.layer.borderColor = UIColor.black.cgColor
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 8
        }
    }
    
    private func configureMajorDetailView() {
        self.majorDetailTitle.alpha = 0
        self.majorDetailView.alpha = 0
        self.genderFrame.transform = CGAffineTransform.init(translationX: 0, y: -160)
    }
    
    private func acticationMajorDetail(section index: Int) {
        NotificationCenter.default.post(name: NotificationName.selectMajor, object: nil, userInfo: [NotificationUserInfo.sectionKey: index])
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.majorDetailTitle.alpha = 1
            self?.majorDetailView.alpha = 1
            self?.genderFrame.transform = CGAffineTransform.identity
        }
    }
    
    private func nextVC() {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: PersonalInfoViewController.identifier) as? PersonalInfoViewController else { return }
        nextVC.signUpInfo = self.signUpInfo
        
        self.title = ""
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}

//MARK: - Connection CollectionViews
extension SurveyViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case CategoryViewController.Identifier.segue:
            guard let destination = segue.destination as? CategoryViewController else { return }
            destination.delegate = self
        case MajorViewController.Identifier.segue:
            guard let destination = segue.destination as? MajorViewController else { return }
            destination.delegate = self
        case MajorDetailViewController.Identifier.segue:
            guard let destination = segue.destination as? MajorDetailViewController else { return }
            destination.delegate = self
        default: return
        }
    }
}

extension SurveyViewController: CategorySetable {
    func didSelectCategory(to category: String) {
        self.signUpInfo?.configureCategory(to: category)
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
