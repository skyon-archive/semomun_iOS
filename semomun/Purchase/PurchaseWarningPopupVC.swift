//
//  PurchaseWarningPopupVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/29.
//

import UIKit

final class PurchaseWarningPopupVC: UIViewController {
    static let identifier = "PurchaseWarningPopupVC"
    static let storyboardName = "HomeSearchBookshelf"
    enum Warning {
        case login, updateUserinfo
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var warningBT: UIButton!
    
    private var type: Warning?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func action(_ sender: Any) {
        guard let type = self.type else { return }
        switch type {
        case .login:
            self.presentingViewController?.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: .showLoginStartVC, object: nil)
            })
        case .updateUserinfo:
            self.presentingViewController?.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: .goToUpdateUserinfo, object: nil)
            })
        }
    }
}

extension PurchaseWarningPopupVC {
    func configureWarning(type: Warning) {
        self.type = type
    }
    
    private func configureUI() {
        guard let type = self.type else { return }
        let fontSize = UIFont.systemFont(ofSize: 18, weight: .heavy)
        
        switch type {
        case .login:
            let title = "회원가입 또는 로그인을 해주세요"
            let attrTitle = NSMutableAttributedString(string: title)
            attrTitle.addAttribute(.font, value: fontSize, range: (title as NSString).range(of: "회원가입"))
            attrTitle.addAttribute(.font, value: fontSize, range: (title as NSString).range(of: "로그인"))
            self.titleLabel.attributedText = attrTitle
            self.configureText(to: "문제집을 구매하기 위해서 로그인이 필요합니다.")
            self.configureActionTitle(to: "로그인 하기")
        case .updateUserinfo:
            let title = "추가적인 정보가 필요해요"
            let attrTitle = NSMutableAttributedString(string: title)
            attrTitle.addAttribute(.font, value: fontSize, range: (title as NSString).range(of: "추가적인 정보"))
            self.titleLabel.attributedText = attrTitle
            self.configureText(to: "문제집을 구매하기 위해\n닉네임과 전화번호를 작성해주세요.")
            self.configureActionTitle(to: "추가정보 작성하기")
        }
    }
    
    private func configureText(to text: String) {
        self.textLabel.text = text
    }
    
    private func configureActionTitle(to title: String) {
        self.warningBT.setTitle(title, for: .normal)
    }
}
