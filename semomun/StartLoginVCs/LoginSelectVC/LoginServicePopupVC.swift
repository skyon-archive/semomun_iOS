//
//  LoginServicePopupVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import SwiftUI

typealias LoginServicePopupNetworkUsecase = MarketingConsentSendable

class LoginServicePopupVC: UIViewController {
    static let identifier = "LoginServicePopupVC"
    static let storyboardName = "StartLogin"
    
    @IBOutlet var checkButtons: [UIButton]!
    @IBOutlet var longTextButtons: [UIButton]!
    
    private lazy var isChecked = [Bool](repeating: false, count: checkButtons.count)
    private var action: (() -> ())?
    private let networkUsecase: LoginServicePopupNetworkUsecase? = NetworkUsecase(network: Network())
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.checkButtons[0..<3].forEach { button in
            let action = UIAction { [weak self] _ in
                self?.isChecked[button.tag].toggle()
                self?.configureButtonUI(button)
            }
            button.addAction(action, for: .touchUpInside)
        }
        guard let agreeAllButton = self.checkButtons.last else { return }
        let action = UIAction { [weak self] _ in
            guard let self = self else { return }
            guard let agreeAllButtonState = self.isChecked.last else { return }
            self.isChecked = [Bool](repeating: !agreeAllButtonState, count: self.isChecked.count)
            self.checkButtons.forEach {
                self.configureButtonUI($0)
            }
        }
        agreeAllButton.addAction(action, for: .touchUpInside)
        
        let longTextButtonSource: [(title: String, txtResourceName: String)] = [
        ("개인정보 처리방침", "personalInformationProcessingPolicy"),
        ("서비스이용약관", "termsAndConditions"),
        ("마케팅 정보 수신", "receiveMarketingInfo")
        ]
        self.longTextButtons.forEach { button in
            let action = UIAction { [weak self] _ in
                let source = longTextButtonSource[button.tag]
                self?.showLongTextVC(title: source.title, txtResourceName: source.txtResourceName, isPopup: true)
            }
            button.addAction(action, for: .touchUpInside)
        }
    }
    
    private func configureButtonUI(_ button: UIButton) {
        guard let check = UIImage(systemName: SemomunImage.circleCheckmark), let checkFilled = UIImage(systemName: SemomunImage.circleCheckmarkFilled) else { return }
        if self.isChecked[button.tag] {
            button.setImage(checkFilled, for: .normal)
            button.tintColor = UIColor(.mainColor)
        } else {
            button.setImage(check, for: .normal)
            button.tintColor = UIColor(.grayDefaultColor)
        }
    }
    
    @IBAction func closeWindow(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func continueRegister(_ sender: Any) {
        if isChecked[0], isChecked[1] {
            self.networkUsecase?.postMarketingConsent(isConsent: isChecked[1]) { status in
                switch status {
                case .SUCCESS:
                    self.dismiss(animated: true)
                    self.action?()
                default:
                    self.showAlertWithOK(title: "네트워크 오류", text: "네트워크 연결 확인 후 다시 시도해주세요.")
                }
            }
        } else {
            self.showAlertWithOK(title: "필수 항목에 동의가 필요합니다.", text: "")
        }
    }
}

extension LoginServicePopupVC {
    func configureConfirmAction(_ action: @escaping () -> Void) {
        self.action = action
    }
}
