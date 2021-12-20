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
}
