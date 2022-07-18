//
//  SelectSocialSignupPopupVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/18.
//

import UIKit

protocol SignupCompleteable: AnyObject {
    func signupComplete()
}

final class SelectSocialSignupPopupVC: UIViewController {
    static let identifier = "SelectSocialSignupPopupVC"
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        return stackView
    }()
    private var usecase: SignupUsecase?
    private weak var delegate: SignupCompleteable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureStackView()
    }
    
    func configureDelegate(_ delegate: SignupCompleteable) {
        self.delegate = delegate
    }
    
    func configureUsecase(_ usecase: SignupUsecase) {
        self.usecase = usecase
    }
}

extension SelectSocialSignupPopupVC {
    private func configureStackView() {
        let appleButton = AppleLoginButton(style: .continue)
        appleButton.addAction(UIAction(handler: { [weak self] _ in
            print("apple")
        }), for: .touchUpInside)
        let googleButton = GoogleLoginButton(style: .continue)
        googleButton.addAction(UIAction(handler: { [weak self] _ in
            print("google")
        }), for: .touchUpInside)
        
        self.stackView.addArrangedSubview(appleButton)
        self.stackView.addArrangedSubview(googleButton)
        
        self.contentView.addSubview(self.stackView)
        NSLayoutConstraint.activate([
            self.stackView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.stackView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 64)
        ])
    }
}
