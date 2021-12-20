//
//  CreateFirstViewController.swift
//  semomun
//
//  Created by Kang Minsang on 2021/09/19.
//

import UIKit

protocol IdPasswdDelegateProtocol{
    func sendDataToCreateSecondViewController(Id_: String, Passwd_: String)
}

class CreateFirstViewController: UIViewController {

    @IBOutlet weak var IDtextField: UITextField!
    @IBOutlet weak var PasswdtextField: UITextField!
    @IBOutlet weak var PwdChecktextField: UITextField!
    
    @IBOutlet weak var PrivacyCheckButton: UIButton!
    
    var delegate: IdPasswdDelegateProtocol? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "회원가입"
    }

    
    
    @IBAction func nextVC(_ sender: Any) {
        if(self.delegate != nil && self.IDtextField != nil && self.PasswdtextField != nil && self.PasswdtextField == self.PwdChecktextField){
            let Id = self.IDtextField.text
            let Passwd = self.PasswdtextField.text
            self.delegate?.sendDataToCreateSecondViewController(Id_: Id!, Passwd_: Passwd!)
            dismiss(animated: true, completion: nil)
            guard let nextVC = self.storyboard?.instantiateViewController(identifier: "CreateSecondViewController") else { return }
            self.title = ""
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
        else{
            // need notification
        }
    }
}
