//
//  SignupVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/15.
//

import UIKit

final class SignupVC: UIViewController {
    static let identifier = "SignupVC"
    /// action
    @IBOutlet weak var postAuthButton: UIButton!
    @IBOutlet weak var checkAuthButton: UIButton!
    /// status line
    @IBOutlet weak var phoneStatusLine: UIView!
    @IBOutlet weak var authStatusLine: UIView!
    /// warning
    @IBOutlet weak var warningPhoneView: UIView!
    @IBOutlet weak var warningAuthView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigationBar()
        // Do any additional setup after loading the view.
        self.postAuthButton.backgroundColor = UIColor.getSemomunColor(.blueRegular)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
   
    @IBAction func postAuthNumber(_ sender: Any) {
        self.phoneStatusLine.backgroundColor = UIColor.systemRed
        self.warningPhoneView.isHidden = false
    }
    
    @IBAction func checkAuthNumber(_ sender: Any) {
        self.authStatusLine.backgroundColor = UIColor.systemRed
        self.warningAuthView.isHidden = false
    }
}

extension SignupVC {
    private func configureNavigationBar() {
        let attributes = [NSAttributedString.Key.font: UIFont.heading4]
        UINavigationBar.appearance().titleTextAttributes = attributes
        self.title = "회원가입"
    }
}
