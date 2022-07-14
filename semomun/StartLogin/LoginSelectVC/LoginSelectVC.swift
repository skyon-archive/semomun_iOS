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

final class LoginSelectVC: UIViewController, StoryboardController {
    static let identifier = "LoginSelectVC"
    static var storyboardNames: [UIUserInterfaceIdiom : String] = [.pad: "Login"]
    
    @IBOutlet weak var semomunTitle: UILabel!
    @IBOutlet weak var reviewButton: UIButton!
    
    var signupInfo: SignupUserInfo?
    private var isSignup: Bool {
        return self.signupInfo != nil
    }
    
    private let signInConfig = GIDConfiguration.init(clientID: "688270638151-kgmitk0qq9k734nq7nh9jl6adhd00b57.apps.googleusercontent.com")
    private var viewModel: LoginSelectVM?
    private var cancellables: Set<AnyCancellable> = []
    
    private enum ButtonUIConstants {
        static let buttonWidth: CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 240 : 345
        static let buttonHeight: CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 45 : 60
        static let buttonRadius: CGFloat = 10
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViewModel()
        self.configureSignInWithAppleButton()
        self.configureSignInWithGoogleButton()
        self.configureReviewButton()
        self.bindAll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func configureReviewButton() {
        let version = String.currentVersion
        let url = NetworkURL.base + "/status/review"
        let param = ["version": version]
        
        Network().request(url: url, param: param, method: .get, tokenRequired: false) { [weak self] result in
            guard let data = result.data,
                  let status = try? JSONDecoder().decode(BooleanResult.self, from: data) else {
                self?.showAlertWithOK(title: "Network Error", text: "Please check internet connection, id and password :)")
                return
            }
            
            if status.result == true {
                self?.reviewButton.isHidden = false
            }
        }
    }
    
    @IBAction func reviewLogin(_ sender: Any) {
        // 누르면 popup 으로 id, password 입력
        let alert = UIAlertController(title: "Semomun Acount Login", message: "Please Enter ID, PASSWORD", preferredStyle: .alert)
        let login = UIAlertAction(title: "Login", style: .default) { [weak self] _ in
            let password = alert.textFields?[1].text ?? "none"
            self?.requestReviewLogin(password: password)
        }
        
        alert.addTextField { id in
            id.placeholder = "ID"
            id.textAlignment = .center
        }
        alert.addTextField { password in
            password.placeholder = "PASSWORD"
            password.textAlignment = .center
            password.isSecureTextEntry = true
        }
        alert.addAction(login)
        
        self.present(alert, animated: true)
    }
    
    private func requestReviewLogin(password: String) {
        self.viewModel?.login(userIDToken: .review(password))
    }
}

extension LoginSelectVC {
    private func configureViewModel() {
        let networkUsecase = NetworkUsecase(network: Network())
        self.viewModel = LoginSelectVM(networkUsecase: networkUsecase, usecase: LoginSignupUsecase(networkUsecase: networkUsecase))
    }
}

// MARK: Apple로 로그인 버튼
extension LoginSelectVC {
    
    private func configureSignInWithAppleButton() {
        let verticalTerm: CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 64 : 73
        let button = self.makeAppleButton()
        self.configureButtonAction(button, loginMethod: .apple)
        self.configureButtonUI(button, verticalSpaceToSemomunTitle: verticalTerm)
    }
    
    private func makeAppleButton() -> ASAuthorizationAppleIDButton {
        if self.isSignup {
            return ASAuthorizationAppleIDButton(type: .signUp, style: .black)
        } else {
            return ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        }
    }
}

// MARK: Google로 로그인 버튼
extension LoginSelectVC {
    private func configureSignInWithGoogleButton() {
        let verticalTerm: CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 125 : 145
        let button = makeGoogleButton()
        let contentContainer = self.makeGoogleButtonContentContainer()
        let googleIcon = self.makeGoogleIcon()
        let text = self.makeGoogleLabel()
        
        self.doNotTranslateAutoresizingMaskIntoConstraints(
            of: button, contentContainer, googleIcon, text
        )
        button.addSubviews(contentContainer, googleIcon, text)

        self.layoutGoogleButtonContentContainer(button: button, container: contentContainer)
        self.layoutGoogleIcon(contentContainer: contentContainer, icon: googleIcon)
        self.layoutGoogleLabel(contentContainer: contentContainer, label: text, icon: googleIcon)
        
        self.configureButtonAction(button, loginMethod: .google)
        self.configureButtonUI(button, verticalSpaceToSemomunTitle: verticalTerm)
    }
    
    private func makeGoogleButton() -> UIControl {
        let signInWithGoogleButton = UIControl()
        signInWithGoogleButton.backgroundColor = .white
        return signInWithGoogleButton
    }
    
    private func makeGoogleButtonContentContainer() -> UIView {
        let buttonContentContainer = UIView()
        return buttonContentContainer
    }
    
    private func makeGoogleIcon() -> UIImageView {
        let googleIconImg = UIImage(.googleLogo)
        let googleIcon = UIImageView(image: googleIconImg)
        return googleIcon
    }
    
    private func makeGoogleLabel() -> UILabel {
        let text = UILabel()
        text.text = self.isSignup ? "Google로 등록" : "Google로 로그인"
        text.textColor = UIColor(.lightGray)
        text.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        return text
    }
    
    private func layoutGoogleButtonContentContainer(button: UIView, container: UIView) {
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: button.centerYAnchor),
        ])
    }
    
    private func layoutGoogleIcon(contentContainer: UIView, icon: UIView) {
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 20),
            icon.heightAnchor.constraint(equalToConstant: 20),
            icon.centerYAnchor.constraint(equalTo: contentContainer.centerYAnchor),
            icon.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor)
        ])
    }
    
    private func layoutGoogleLabel(contentContainer: UIView, label: UIView, icon: UIView) {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 5),
            label.centerYAnchor.constraint(equalTo: contentContainer.centerYAnchor),
            label.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor)
        ])
    }
    
    private func doNotTranslateAutoresizingMaskIntoConstraints(of views: UIView...) {
        views.forEach { $0.translatesAutoresizingMaskIntoConstraints = true }
    }
}

// MARK: 버튼 configure 공통
extension LoginSelectVC {
    private func configureButtonAction(_ button: UIControl, loginMethod: LoginMethod) {
        let action = UIAction { [weak self] _ in
            self?.signInButtonAction(loginMethod: loginMethod)
        }
        button.addAction(action, for: .touchUpInside)
    }
    
    private func configureButtonUI(_ button: UIView, verticalSpaceToSemomunTitle: CGFloat) {
        self.configureButtonLayer(button)
        self.configureButtonLayout(button, verticalSpaceToSemomunTitle: verticalSpaceToSemomunTitle)
    }
    
    private func configureButtonLayer(_ button: UIView) {
        button.layer.cornerRadius = Self.ButtonUIConstants.buttonRadius
        button.addShadow(direction: .bottom)
    }
    
    private func configureButtonLayout(_ button: UIView, verticalSpaceToSemomunTitle: CGFloat) {
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: Self.ButtonUIConstants.buttonWidth),
            button.heightAnchor.constraint(equalToConstant: Self.ButtonUIConstants.buttonHeight),
            button.topAnchor.constraint(equalTo: self.semomunTitle.bottomAnchor, constant: verticalSpaceToSemomunTitle),
            button.centerXAnchor.constraint(equalTo: self.semomunTitle.centerXAnchor)
        ])
    }
}

// MARK: Bindings
extension LoginSelectVC {
    private func bindAll() {
        self.bindAlert()
        self.bindStatus()
    }
    private func bindAlert() {
        self.viewModel?.$alert
            .receive(on: DispatchQueue.main)
            .sink { [weak self] alert in
                if let alert = alert {
                    self?.showAlertWithOK(title: alert.title, text: alert.description ?? "")
                }
            }
            .store(in: &self.cancellables)
    }
    private func bindStatus() {
        self.viewModel?.$status
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                switch status {
                case .userNotExist:
                    self?.showUserNotExistAlert()
                case .userAlreadyExist:
                    self?.showUserAlreadyExistAlert()
                case .complete:
                    self?.showCompleteAlert()
                case .none:
                    break
                }
            }
            .store(in: &self.cancellables)
    }
    
    private func showUserNotExistAlert() {
        self.showAlertWithOK(title: "회원 정보가 없습니다", text: "회원가입을 진행해주시기 바랍니다.") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    private func showUserAlreadyExistAlert() {
        let alertController = UIAlertController(title: "이미 존재하는 계정", message: "방금 입력하신 정보로 계정 정보를 덮어씌울까요?", preferredStyle: .alert)
        let alertActions = [
            UIAlertAction(title: "취소", style: .default),
            UIAlertAction(title: "덮어씌우기", style: .default) { [weak self] _ in
                guard let signupUserInfo = self?.signupInfo else {
                    assertionFailure()
                    return
                }
                self?.viewModel?.pasteUserInfo(signupUserInfo: signupUserInfo)
            }
        ]
        alertActions.forEach { alertController.addAction($0) }
        self.present(alertController, animated: true)
    }
    
    private func showCompleteAlert() {
        self.showAlertWithOK(title: "로그인 완료", text: "로그인에 성공하였습니다.") { [weak self] in
            self?.presentingViewController?.dismiss(animated: true, completion: nil)
            NotificationCenter.default.post(name: .logined, object: nil)
        }
    }
}

// MARK: 로그인 버튼 액션
extension LoginSelectVC {
    private enum LoginMethod {
        case apple, google
    }
    
    private func signInButtonAction(loginMethod: LoginMethod) {
        if self.isSignup {
            self.showServiceInfoView(loginMethod: loginMethod)
        } else {
            self.askLoginTo(loginMethod: loginMethod)
        }
    }
    
    private func showServiceInfoView(loginMethod: LoginMethod) {
        guard let serviceInfoVC = UIStoryboard(name: LoginServicePopupVC.storyboardName, bundle: nil)
                .instantiateViewController(withIdentifier: LoginServicePopupVC.identifier) as? LoginServicePopupVC else { return }
        serviceInfoVC.configureConfirmAction { [weak self] marketingAgreed in
            self?.signupInfo?.marketing = marketingAgreed
            self?.askLoginTo(loginMethod: loginMethod)
        }
        self.present(serviceInfoVC, animated: true, completion: nil)
    }
    
    private func askLoginTo(loginMethod: LoginMethod) {
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

extension LoginSelectVC: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            guard let tokenData = appleIDCredential.identityToken, // 할때마다 생성되는 token 값 (변동있음)
                  let token = String(data: tokenData, encoding: .utf8) else { return }
            self.continueAccountSetting(userIDToken: .apple(token))
        default: break
        }
    }
    
    func authorizationGoogleController(user: GIDGoogleUser) {
        user.authentication.do { authentication, error in
            guard error == nil else { return }
            guard let authentication = authentication,
                  let idToken = authentication.idToken else { return }
            self.continueAccountSetting(userIDToken: .google(idToken))
        }
    }
    
    private func continueAccountSetting(userIDToken: NetworkURL.UserIDToken) {
        if let signupInfo = self.signupInfo {
            self.viewModel?.signup(userIDToken: userIDToken, userInfo: signupInfo)
        } else {
            self.viewModel?.login(userIDToken: userIDToken)
        }
    }
}
