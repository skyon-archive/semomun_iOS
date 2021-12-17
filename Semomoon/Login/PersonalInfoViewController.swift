//
//  PersonalInfoViewController.swift
//  Semomoon
//
//  Created by Yoonho Shin on 2021/11/21.
//

import UIKit

class PersonalInfoViewController: UIViewController {
    static let identifier = "PersonalInfoViewController"

    @IBOutlet weak var year: UIButton!
    @IBOutlet weak var month: UIButton!
    @IBOutlet weak var day: UIButton!
    @IBOutlet weak var school: UIButton!
    @IBOutlet weak var graduation: UIButton!
    private var infoFilled: Bool = false
    var signUpInfo: SignUpInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func tapYear(_ sender: Any) {
    }
    @IBAction func tapMonth(_ sender: Any) {
    }
    @IBAction func tapDay(_ sender: Any) {
    }
    @IBAction func tapSchool(_ sender: Any) {
    }
    @IBAction func tapGraduation(_ sender: Any) {
    }
    
    @IBAction func completeSignup(_ sender: Any) {
        infoFilled = true
        if(infoFilled) {
//            guard let name = self.name.text,
//                  let phoneNumber = self.phone.text else { return }
            self.signUpInfo?.configureSecond(desiredCategory: [], field: "", interest: [])
            self.signUpInfo?.configureThird(birthdayYear: "2021", birthdayMonth: "11", birthdayDay: "11", schoolName: "Sky", graduationStatus: "Yes")
            // Backend 확인 이후 로직
            UserDefaults.standard.setValue(true, forKey: "logined")
            guard let nextVC = self.storyboard?.instantiateViewController(identifier: MainViewController.identifier) else { return }
            
            nextVC.modalPresentationStyle = .fullScreen
            self.present(nextVC, animated: true, completion: nil)
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
