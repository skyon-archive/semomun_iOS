//
//  PersonalSettingNameViewController.swift
//  Semomoon
//
//  Created by Kang Minsang on 2021/12/18.
//

import UIKit

class PersonalSettingNameViewController: UIViewController {
    static let identifier = "PersonalSettingNameViewController"
    
    @IBOutlet weak var frameView: UIView!
    @IBOutlet weak var nameFrameView: UIView!
//    @IBOutlet weak var nickNameFrameView: UIView!
    @IBOutlet weak var nameField: UITextField!
//    @IBOutlet weak var nicknameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.configureName(to: "홍길동")
        self.configureNickName(to: "할빈당")
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension PersonalSettingNameViewController {
    func configureUI() {
        self.frameView.clipsToBounds = true
        self.frameView.layer.cornerRadius = 25
        self.setShadow(to: self.nameFrameView)
//        self.setShadow(to: self.nickNameFrameView)
    }
    
    func setShadow(to view: UIView) {
        view.layer.cornerRadius = 12
        view.layer.shadowOffset = CGSize(width: 5, height: 5)
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 8
        view.layer.shadowColor = UIColor.lightGray.cgColor
    }
    
    func configureName(to name: String) {
        self.nameField.text = name
    }
    
    func configureNickName(to nickName: String) {
//        self.nicknameField.text = nickName
    }
}
