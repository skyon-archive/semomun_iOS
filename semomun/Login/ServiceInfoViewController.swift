//
//  ServiceInfoViewController.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/05.
//

import UIKit

protocol RegisgerServiceSelectable: AnyObject {
    func appleLogin()
    func googleLogin()
}

class ServiceInfoViewController: UIViewController {
    static let identifier = "ServiceInfoViewController"

    @IBOutlet weak var frameView: UIView!
    @IBOutlet weak var innerFrameview: UIView!
    @IBOutlet weak var accept: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    weak var delegate: RegisgerServiceSelectable?
    var tag: Int?
    var isSignin: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.configureText()
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
        guard let tag = tag else { return }
        if !self.checkButton.isSelected {
            self.showAlertWithOK(title: "동의를 해주시기 바랍니다", text: "")
        } else {
            self.dismiss(animated: true, completion: nil)
            if tag == 0 {
                delegate?.appleLogin()
            } else {
                delegate?.googleLogin()
            }
        }
    }
}

extension ServiceInfoViewController {
    private func configureUI() {
        self.frameView.clipsToBounds = true
        self.frameView.layer.cornerRadius = 44
        self.innerFrameview.clipsToBounds = true
        self.innerFrameview.layer.cornerRadius = 34
        self.innerFrameview.layer.borderWidth = 1
        self.innerFrameview.layer.borderColor = UIColor(named: SemomunColor.mainColor)?.cgColor
        self.accept.clipsToBounds = true
        self.accept.cornerRadius = 10
    }
    
    private func configureText() {
        if !self.isSignin {
            self.accept.setTitle("로그인하기", for: .normal)
        }
    }
    
    private func loadPersonalPolicy() {
        guard let filepath = Bundle.main.path(forResource: "personalInformationProcessingPolicy", ofType: "txt") else { return }
        do {
            let text = try String(contentsOfFile: filepath)
            self.popupTextViewController(title: "개인정보 처리방침", text: text)
        } catch {
            self.showAlertWithOK(title: "에러", text: "파일로딩에 실패하였습니다.")
        }
    }
    
    private func loadTermsAndCondition() {
        guard let filepath = Bundle.main.path(forResource: "termsAndConditions", ofType: "txt") else { return }
        do {
            let text = try String(contentsOfFile: filepath)
            self.popupTextViewController(title: "이용약관", text: text)
        } catch {
            self.showAlertWithOK(title: "에러", text: "파일로딩에 실패하였습니다.")
        }
    }
    
    private func popupTextViewController(title: String, text: String) {
        let vc = LongTextPopupViewController(title: title, text: text)
        present(vc, animated: true, completion: nil)
    }
}
