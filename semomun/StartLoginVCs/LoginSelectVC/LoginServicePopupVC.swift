//
//  LoginServicePopupVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import SwiftUI

typealias LoginServicePopupNetworkUsecase = UserInfoSendable

class LoginServicePopupVC: UIViewController {
    static let identifier = "LoginServicePopupVC"
    static let storyboardName = "StartLogin"
    
    @IBOutlet var checkButtons: [UIButton]!
    @IBOutlet var longTextButtons: [UIButton]!
    @IBOutlet weak var registerButton: UIButton!
    
    private lazy var isChecked = [Bool](repeating: false, count: checkButtons.count)
    private var action: (() -> ())?
    private var networkUsecase: LoginServicePopupNetworkUsecase? = NetworkUsecase(network: Network())
    private var canRegister: Bool {
        return isChecked[0] && isChecked[1]
    }
    
    private let normalCheckButtonsIndex = 0..<3
    private let marketingAgreeButtonIndex = 2
    private let agreeAllButtonIndex = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNormalButtons()
        self.configureAgreeAllButton()
        self.configureLongTextButtons()
        self.updateUIOfRegisterButton()
    }
    
    @IBAction func closeWindow(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func continueRegister(_ sender: Any) {
        guard self.canRegister else { return }
        let marketingAgreed = isChecked[self.marketingAgreeButtonIndex]
        self.networkUsecase?.postMarketingConsent(isConsent: marketingAgreed) { status in
            switch status {
            case .SUCCESS:
                self.dismiss(animated: true)
                self.action?()
            default:
                self.showAlertWithOK(title: "네트워크 오류", text: "네트워크 연결 확인 후 다시 시도해주세요.")
            }
        }
    }
}

// MARK: Public configure
extension LoginServicePopupVC {
    func configureConfirmAction(_ action: @escaping () -> Void) {
        self.action = action
    }
}

// MARK: Configure buttons
extension LoginServicePopupVC {
    private func configureNormalButtons() {
        self.checkButtons[self.normalCheckButtonsIndex].forEach { button in
            let action = UIAction { [weak self] _ in
                guard let self = self else { return }
                self.isChecked[button.tag].toggle()
                let agreeAllButtonStatus = self.isChecked[self.normalCheckButtonsIndex].allSatisfy({$0})
                self.isChecked[self.agreeAllButtonIndex] = agreeAllButtonStatus
                self.updateUIOfAllButtons()
            }
            button.addAction(action, for: .touchUpInside)
        }
    }
    
    private func configureAgreeAllButton() {
        let action = UIAction { [weak self] _ in
            guard let self = self,
            let agreeAllButtonState = self.isChecked.last else { return }
            self.isChecked = self.isChecked.map { _ in !agreeAllButtonState }
            self.updateUIOfAllButtons()
        }
        self.checkButtons[self.agreeAllButtonIndex].addAction(action, for: .touchUpInside)
    }
    
    private func configureLongTextButtons() {
        let longTextButtonSource: [(title: String, txtResourceName: String)] = [
        ("개인정보 처리방침", "personalInformationProcessingPolicy"),
        ("서비스이용약관", "termsAndConditions"),
        ("마케팅 정보 수신", "receiveMarketingInfo")]
        self.longTextButtons.forEach { button in
            let action = UIAction { [weak self] _ in
                let source = longTextButtonSource[button.tag]
                self?.showLongTextVC(title: source.title, txtResourceName: source.txtResourceName, isPopup: true)
            }
            button.addAction(action, for: .touchUpInside)
        }
    }
}

// MARK: Update button UI
extension LoginServicePopupVC {
    private func updateUIOfAllButtons() {
        self.checkButtons.forEach {
            self.updateUI(of: $0)
        }
        self.updateUIOfRegisterButton()
    }
    // isChecked를 버튼들에 반영
    private func updateUI(of button: UIButton) {
        let check = UIImage(.circleCheckmark)
        let checkFilled = UIImage(.circleCheckmarkFilled) 
        if self.isChecked[button.tag] {
            button.setImage(checkFilled, for: .normal)
            button.tintColor = UIColor(.mainColor)
        } else {
            button.setImage(check, for: .normal)
            button.tintColor = UIColor(.grayDefaultColor)
        }
    }
    
    private func updateUIOfRegisterButton() {
        self.registerButton.layer.opacity = self.canRegister ? 1 : 0.3
    }
}
