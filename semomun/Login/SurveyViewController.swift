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
    
    var surveyFilled: Bool = false
    var signUpInfo: SignUpInfo!
    @IBOutlet var gender: [UIButton]!
    @IBOutlet weak var majorDetailTitle: UILabel!
    @IBOutlet weak var majorDetailView: UIView!
    @IBOutlet weak var genderFrame: UIView!
    
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
        guard let sex = sender.titleLabel?.text else { return }
        print(sex)
        switch sender.tag {
        case 0:
            self.didSelect(to: gender[0])
            self.diSelect(from: gender[1])
        case 1:
            self.didSelect(to: gender[1])
            self.diSelect(from: gender[0])
        default: return
        }
    }
    
    @IBAction func nextVC(_ sender: Any) {
        surveyFilled = true
        if(surveyFilled) {
            self.signUpInfo.configureSecond(desiredCategory: [], field: "", interest: [])
            self.nextVC()
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
        gender.forEach { button in
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
    func didSelectCategory(to: String) {
        print(to)
    }
}
extension SurveyViewController: MajorSetable {
    func didSelectMajor(section index: Int, to: String) {
        self.acticationMajorDetail(section: index)
        print(to)
    }
}
extension SurveyViewController: MajorDetailSetable {
    func didSelectMajorDetail(to: String) {
        print(to)
    }
}
