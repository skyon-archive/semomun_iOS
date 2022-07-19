//
//  SelectSocialSignupPopupVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/18.
//

import UIKit
import Combine
import GoogleSignIn
import AuthenticationServices

protocol SignupCompleteable: AnyObject {
    func signupComplete()
    func backToLogin()
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
    private var cancellables: Set<AnyCancellable> = []
    private let signInConfig = GIDConfiguration.init(clientID: "688270638151-kgmitk0qq9k734nq7nh9jl6adhd00b57.apps.googleusercontent.com")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureStackView()
        self.bindAll()
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
            self?.appleSignUpButtonPressed()
        }), for: .touchUpInside)
        let googleButton = GoogleLoginButton(style: .continue)
        googleButton.addAction(UIAction(handler: { [weak self] _ in
            self?.googleSignUpButtonPressed()
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

extension SelectSocialSignupPopupVC {
    private func bindAll() {
        self.bindSignupCompleted()
        self.bindSignupError()
    }
    
    private func bindSignupCompleted() {
        self.usecase?.$signupCompleted
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] completed in
                guard completed == true else { return }
                self?.presentingViewController?.dismiss(animated: true, completion: { [weak self] in
                    self?.delegate?.signupComplete()
                })
            })
            .store(in: &self.cancellables)
    }
    
    private func bindSignupError() {
        self.usecase?.$signupError
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] error in
                guard let error = error else { return }
                switch error {
                case .networkError:
                    self?.showAlertWithOK(title: "네트워크 에러", text: "네트워크를 확인 후 다시해주세요")
                case .localError:
                    self?.showAlertWithOK(title: "정보 저장 실패", text: "정보를 확인 후 다시 시도해주세요")
                case .userAlreadyExist:
                    self?.showAlertWithOK(title: "회원정보가 존재합니다", text: "로그인 해주시기 바랍니다") { [weak self] in
                        self?.presentingViewController?.dismiss(animated: true, completion: { [weak self] in
                            self?.delegate?.backToLogin()
                        })
                    }
                }
            })
            .store(in: &self.cancellables)
    }
}

// Apple, Google 관련 로직
extension SelectSocialSignupPopupVC {
    private func appleSignUpButtonPressed() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func googleSignUpButtonPressed() {
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
            guard error == nil else { return }
            guard let user = user else { return }
            self.authorizationGoogleController(user: user)
        }
    }
}

extension SelectSocialSignupPopupVC: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            guard let tokenData = appleIDCredential.identityToken, // 할때마다 생성되는 token 값 (변동있음)
                  let token = String(data: tokenData, encoding: .utf8) else { return }
            self.usecase?.signup(userIDToken: .apple(token))
        default: break
        }
    }
    
    private func authorizationGoogleController(user: GIDGoogleUser) {
        user.authentication.do { authentication, error in
            guard error == nil else { return }
            guard let authentication = authentication,
                  let idToken = authentication.idToken else { return }
            self.usecase?.signup(userIDToken: .google(idToken))
        }
    }
}
