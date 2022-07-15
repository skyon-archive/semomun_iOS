//
//  SignupVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/15.
//

import UIKit

final class SignupVC: UIViewController {
    static let identifier = "SignupVC"
    /// for design
    @IBOutlet weak var searchIcon: UIImageView!
    /// action
    @IBOutlet weak var postAuthButton: UIButton!
    @IBOutlet weak var checkAuthButton: UIButton!
    /// status line
    @IBOutlet weak var phoneStatusLine: UIView!
    @IBOutlet weak var authStatusLine: UIView!
    /// warning
    @IBOutlet weak var warningPhoneView: UIView!
    @IBOutlet weak var warningAuthView: UIView!
    /// majors
    @IBOutlet var majorButtons: [UIButton]!
    @IBOutlet var majorDetailButtons: [UIButton]!
    /// select agrees
    @IBOutlet var checkButtons: [UIButton]!
    @IBOutlet var longTextButtons: [UIButton]!
    /// complete
    @IBOutlet weak var SignupCompleteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigationBar()
        self.configureUI()
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
    
    @IBAction func checkNameDuplicated(_ sender: Any) {
        
    }
    
    @IBAction func selectMajor(_ sender: UIButton) {
        self.majorButtons[sender.tag].isSelected.toggle()
        self.updateButtons(self.majorButtons, index: sender.tag)
    }
    
    @IBAction func selectMajorDetail(_ sender: UIButton) {
        self.majorDetailButtons[sender.tag].isSelected.toggle()
        self.updateButtons(self.majorDetailButtons, index: sender.tag)
    }
    
    
    @IBAction func showSchoolSelectPopup(_ sender: Any) {
        
    }
    
    @IBAction func selectAgree(_ sender: UIButton) {
        self.checkButtons[sender.tag].isSelected.toggle()
        if sender.tag == 0 {
            self.updateAllChecks(to: self.checkButtons[0].isSelected)
        }
    }
    
    @IBAction func showDetailPopup(_ sender: UIButton) {
        print(sender.tag)
    }
    
}

extension SignupVC {
    private func configureNavigationBar() {
        let attributes = [NSAttributedString.Key.font: UIFont.heading4]
        UINavigationBar.appearance().titleTextAttributes = attributes
        self.title = "회원가입"
    }
    
    private func configureUI() {
        self.searchIcon.setSVGTintColor(to: UIColor.getSemomunColor(.black))
    }
}

extension SignupVC {
    private func updateButtons(_ buttons: [UIButton], index: Int) {
        for (idx, button) in buttons.enumerated() {
            if idx == index {
                button.backgroundColor = UIColor.getSemomunColor(.orangeRegular)
                button.setTitleColor(UIColor.getSemomunColor(.white), for: .normal)
                button.layer.borderColor = UIColor.clear.cgColor
            } else {
                button.backgroundColor = UIColor.getSemomunColor(.white)
                button.setTitleColor(UIColor.getSemomunColor(.lightGray), for: .normal)
                button.layer.borderColor = UIColor.getSemomunColor(.border).cgColor
            }
        }
    }
    
    private func updateAllChecks(to: Bool) {
        self.checkButtons.forEach { $0.isSelected = to }
    }
}
