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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dump(signUpInfo)
        // Do any additional setup after loading the view.
    }
    

    @IBAction func nextVC(_ sender: Any) {
        surveyFilled = true
        if(surveyFilled){
//            guard let name = self.name.text,
//                  let phoneNumber = self.phone.text else { return }
            self.signUpInfo.configureSecond(desiredCategory: [], field: "", interest: [])
            guard let nextVC = self.storyboard?.instantiateViewController(identifier: PersonalInfoViewController.identifier) as? PersonalInfoViewController else { return }
            self.title = ""
            nextVC.signUpInfo = self.signUpInfo
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
