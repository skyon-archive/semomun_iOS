//
//  SurveyViewController.swift
//  Semomoon
//
//  Created by Yoonho Shin on 2021/11/21.
//

import UIKit

class SurveyViewController: UIViewController {
    static let identifier = "SurveyViewController"
    
    var surveyFilled: Bool = false
    var signUpInfo: SignUpInfo!
    @IBOutlet var gender: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureGengerUI()
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
        if(surveyFilled){
            self.signUpInfo.configureSecond(desiredCategory: [], field: "", interest: [])
            guard let nextVC = self.storyboard?.instantiateViewController(identifier: PersonalInfoViewController.identifier) as? PersonalInfoViewController else { return }
            self.title = ""
            nextVC.signUpInfo = self.signUpInfo
            self.navigationController?.pushViewController(nextVC, animated: true)
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
    func didSelectMajor(to: String) {
        print(to)
    }
}
