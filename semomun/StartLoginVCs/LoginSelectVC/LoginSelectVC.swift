//
//  LoginSelectVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import Combine
import AuthenticationServices
import GoogleSignIn

final class LoginSelectVC: UIViewController {
    static let identifier = "LoginSelectVC"
    static let storyboardName = "StartLogin"
    
    @IBOutlet weak var semomunTitle: UILabel!
    
    var showPopup = true
    var signupInfo: SignupUserInfo?
    
    private let buttonWidth: CGFloat = 309
    private let buttonHeight: CGFloat = 54
    private let buttonRadius: CGFloat = 10
    private let signInConfig = GIDConfiguration.init(clientID: "688270638151-kgmitk0qq9k734nq7nh9jl6adhd00b57.apps.googleusercontent.com")
    
    private let viewModel = LoginSelectVM(networkUsecase: NetworkUsecase(network: Network()))
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureSignInWithAppleButton()
        self.configureSignInWithGoogleButton()
        self.bindAll()
    }
}

extension LoginSelectVC {
    private func bindAll() {
        self.bindAlert()
        self.bindStatus()
    }
    private func bindAlert() {
        self.viewModel.$alert
            .receive(on: DispatchQueue.main)
            .sink { [weak self] alert in
                if let alert = alert {
                    self?.showAlertWithOK(title: alert.title, text: alert.description ?? "")
                }
            }
            .store(in: &self.cancellables)
    }
    private func bindStatus() {
        self.viewModel.$status
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                switch status {
                case .userNotExist:
                    self?.showAlertWithOK(title: "회원 정보가 없습니다", text: "회원가입을 진행해주시기 바랍니다.") {
                        self?.navigationController?.popViewController(animated: true)
                    }
                case .userAlreadyExist:
                    let alertController = UIAlertController(title: "이미 존재하는 계정", message: "방금 입력하신 정보로 계정 정보를 덮어씌울까요?", preferredStyle: .alert)
                    let alertActions = [
                        UIAlertAction(title: "취소", style: .default),
                        UIAlertAction(title: "덮어씌우기", style: .default) { [weak self] _ in
                            // TODO: 잘 덮어씌우기
                        }
                    ]
                    alertActions.forEach { alertController.addAction($0) }
                    self?.present(alertController, animated: true)
                case .complete:
                    self?.showAlertWithOK(title: "로그인 완료", text: "로그인에 성공하였습니다.") { [weak self] in
                        self?.presentingViewController?.dismiss(animated: true, completion: nil)
                        NotificationCenter.default.post(name: .logined, object: nil)
                    }
                case .none:
                    break
                }
                
            }
            .store(in: &self.cancellables)
    }
}

// MARK: 로그인 버튼 액션
extension LoginSelectVC {
    private enum LoginMethod {
        case apple, google
    }
    
    private func signInButtonAction(loginMethod: LoginMethod) {
        if self.showPopup {
            self.showServiceInfoView(loginMethod: loginMethod)
        } else {
            self.performLogin(loginMethod: loginMethod)
        }
    }
    
    private func showServiceInfoView(loginMethod: LoginMethod) {
        guard let serviceInfoVC = UIStoryboard(name: LoginServicePopupVC.storyboardName, bundle: nil)
                .instantiateViewController(withIdentifier: LoginServicePopupVC.identifier) as? LoginServicePopupVC else { return }
        serviceInfoVC.configureConfirmAction { [weak self] in
            self?.performLogin(loginMethod: loginMethod)
        }
        self.present(serviceInfoVC, animated: true, completion: nil)
    }
    
    private func performLogin(loginMethod: LoginMethod) {
        switch loginMethod {
        case .apple:
            self.appleSignInButtonPressed()
        case .google:
            self.googleSignInButtonPressed()
        }
    }
    
    private func appleSignInButtonPressed() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func googleSignInButtonPressed() {
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
            guard error == nil else { return }
            guard let user = user else { return }
            self.authorizationGoogleController(user: user)
        }
    }
}

extension LoginSelectVC {
    /// 로그인 시도 후 userID를 받아 처리
    private func processLogin(userIDToken: NetworkURL.UserIDToken) {
        if let signupInfo = self.signupInfo {
            self.viewModel.signup(userIDToken: userIDToken, userInfo: signupInfo)
        } else {
            self.viewModel.login(userIDToken: userIDToken)
        }
    }
}

// MARK: AuthenticationServices Protocols
extension LoginSelectVC: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            guard let tokenData = appleIDCredential.identityToken, // 할때마다 생성되는 token 값 (변동있음)
                  let token = String(data: tokenData, encoding: .utf8) else { return }
            self.processLogin(userIDToken: .apple(token))
        default: break
        }
    }
    
    func authorizationGoogleController(user: GIDGoogleUser) {
        user.authentication.do { authentication, error in
            guard error == nil else { return }
            guard let authentication = authentication,
                  let idToken = authentication.idToken else { return }
            self.processLogin(userIDToken: .google(idToken))
        }
    }
}

// MARK: 버튼 디자인/기능 설정
extension LoginSelectVC {
    private func configureSignInWithAppleButton() {
        let authorizationButton: ASAuthorizationAppleIDButton
        if self.signupInfo != nil {
            authorizationButton = ASAuthorizationAppleIDButton(type: .signUp, style: .black)
        } else {
            authorizationButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        }
        authorizationButton.layer.cornerRadius = self.buttonRadius
        let action = UIAction { [weak self] _ in
            self?.signInButtonAction(loginMethod: .apple)
        }
        authorizationButton.addAction(action, for: .touchUpInside)
        self.configureSignInButtonLayout(authorizationButton, verticalSpaceToSemomunTitle: 73)
    }
    
    private func configureSignInWithGoogleButton() {
        let signInWithGoogleButton = UIControl()
        signInWithGoogleButton.backgroundColor = .white
        signInWithGoogleButton.layer.cornerRadius = self.buttonRadius
        
        // 버튼 내용물의 container view
        let buttonContentContainer = UIView()
        signInWithGoogleButton.addSubview(buttonContentContainer)
        buttonContentContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonContentContainer.centerXAnchor.constraint(equalTo: signInWithGoogleButton.centerXAnchor),
            buttonContentContainer.centerYAnchor.constraint(equalTo: signInWithGoogleButton.centerYAnchor),
        ])
        
        // Google 로고
        let googleIconImg = UIImage(.googleLogo)
        let googleIcon = UIImageView(image: googleIconImg)
        googleIcon.translatesAutoresizingMaskIntoConstraints = false
        buttonContentContainer.addSubview(googleIcon)
        NSLayoutConstraint.activate([
            googleIcon.widthAnchor.constraint(equalToConstant: 20),
            googleIcon.heightAnchor.constraint(equalToConstant: 20),
            googleIcon.centerYAnchor.constraint(equalTo: buttonContentContainer.centerYAnchor),
            googleIcon.leadingAnchor.constraint(equalTo: buttonContentContainer.leadingAnchor)
        ])
        
        // Google로 로그인 라벨
        let text = UILabel()
        text.text = self.signupInfo != nil ? "Google로 등록" : "Google로 로그인"
        text.textColor = UIColor(.grayTextColor)
        text.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        text.translatesAutoresizingMaskIntoConstraints = false
        buttonContentContainer.addSubview(text)
        NSLayoutConstraint.activate([
            text.leadingAnchor.constraint(equalTo: googleIcon.trailingAnchor, constant: 5),
            text.centerYAnchor.constraint(equalTo: buttonContentContainer.centerYAnchor),
            text.trailingAnchor.constraint(equalTo: buttonContentContainer.trailingAnchor)
        ])
        
        // Action 설정
        let action = UIAction { [weak self] _ in
            self?.signInButtonAction(loginMethod: .google)
        }
        signInWithGoogleButton.addAction(action, for: .touchUpInside)
        
        self.configureSignInButtonLayout(signInWithGoogleButton, verticalSpaceToSemomunTitle: 145)
    }
    
    private func configureSignInButtonLayout(_ button: UIView, verticalSpaceToSemomunTitle: CGFloat) {
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: self.buttonWidth),
            button.heightAnchor.constraint(equalToConstant: self.buttonHeight),
            button.topAnchor.constraint(equalTo: self.semomunTitle.bottomAnchor, constant: verticalSpaceToSemomunTitle),
            button.centerXAnchor.constraint(equalTo: self.semomunTitle.centerXAnchor)
        ])
        button.addShadow(direction: .bottom)
    }
}
