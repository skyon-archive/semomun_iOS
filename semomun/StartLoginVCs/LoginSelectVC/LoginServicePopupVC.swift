//
//  LoginServicePopupVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit

class LoginServicePopupVC: UIViewController {
    static let identifier = "LoginServicePopupVC"
    static let storyboardName = "StartLogin"

    @IBOutlet weak var frameView: UIView!
    @IBOutlet weak var innerFrameview: UIView!
    @IBOutlet weak var accept: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    private var action: (() -> ())?
    var tag: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func toggleAccept(_ sender: Any) {
        self.checkButton.isSelected.toggle()
    }
    
    @IBAction func showPersonalPolicy(_ sender: Any) {
        self.loadPersonalPolicy()
    }
    
    @IBAction func showTermsAndConditions(_ sender: Any) {
        self.loadTermsAndCondition()
    }
    
    @IBAction func acceptAll(_ sender: Any) {
        if !self.checkButton.isSelected {
            self.showAlertWithOK(title: "동의를 해주시기 바랍니다", text: "")
        } else {
            self.dismiss(animated: true) {
                self.action?()
            }
        }
    }
}

extension LoginServicePopupVC {
    func configureConfirmAction(_ action: @escaping () -> Void) {
        self.action = action
    }
    
    private func configureUI() {
        self.frameView.clipsToBounds = true
        self.frameView.layer.cornerRadius = 44
        self.innerFrameview.clipsToBounds = true
        self.innerFrameview.layer.cornerRadius = 34
        self.innerFrameview.layer.borderWidth = 1
        self.innerFrameview.layer.borderColor = UIColor(.mainColor)?.cgColor
        self.accept.clipsToBounds = true
        self.accept.layer.cornerRadius = 10
    }
    
    private func loadPersonalPolicy() {
        self.popupLongTextVC(title: "개인정보 처리방침", txtResourceName: "personalInformationProcessingPolicy")
    }
    
    private func loadTermsAndCondition() {
        self.popupLongTextVC(title: "서비스이용약관", txtResourceName: "termsAndConditions")
    }
}
