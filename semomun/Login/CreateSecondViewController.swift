//
//  CreateSecondViewController.swift
//  semomun
//
//  Created by Kang Minsang on 2021/09/22.
//

import UIKit

class CreateSecondViewController: UIViewController {
    var Id: String!
    var Passwd: String!

    @IBOutlet weak var NameTextField: UITextField!
    @IBOutlet weak var SchoolTextField: UITextField!
    @IBOutlet weak var GradeSelectButton: UIButton!
    @IBOutlet weak var FieldSelectButton: UIButton!
    @IBOutlet weak var CurrentScoreSelectButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "회원가입"
    }
    
    func sendDataToCreateSecondViewController(Id_: String, Passwd_: String){
        Id = Id_
        Passwd = Passwd_
    }
    
    func SignUpDB(){
        // Send Struct of Private information to DB and get approval
    }
    
    @IBAction func finish(_ sender: Any) {
        if(NameTextField != nil && SchoolTextField != nil && GradeSelectButton != nil && FieldSelectButton != nil && CurrentScoreSelectButton != nil){
            // 유저 회원가입 완료
            UserDefaults.standard.setValue(true, forKey: "logined")
            guard let nextVC = self.storyboard?.instantiateViewController(identifier: "MainViewController") else { return }
            nextVC.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
        
            self.present(nextVC, animated: false, completion: nil) // present
        }
        else{
            // need notification
        }
    }
}
