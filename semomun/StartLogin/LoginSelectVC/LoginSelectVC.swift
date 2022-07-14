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
    @IBOutlet weak var cancelButton: UIButton!
    private var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(.logo)
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 197),
            imageView.heightAnchor.constraint(equalToConstant: 160)
        ])
        return imageView
    }()
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "지금 로그인하고\n세상의 모든 문제집을 만나보세요"
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = UIFont.heading1
        label.textColor = UIColor.getSemomunColor(.black)
        return label
    }()
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.clipsToBounds = false
        stackView.backgroundColor = .clear
        
        stackView.addArrangedSubview(self.configureLoginWithAppleButton())
        stackView.addArrangedSubview(self.configureLoginWithGoogleButton())
        stackView.addArrangedSubview(self.configureSignupButton())
        
        return stackView
    }()
    private var verticalConstraint: NSLayoutConstraint?
    private var appleLoginButton = AppleLoginButton()
    
    private let signInConfig = GIDConfiguration.init(clientID: "688270638151-kgmitk0qq9k734nq7nh9jl6adhd00b57.apps.googleusercontent.com")
    private var viewModel: LoginSelectVM?
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViewModel()
        self.configureView()
        self.configureVerticalConstraiint()
        self.checkReviewButton()
        self.bindAll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { [weak self] _ in
            UIView.performWithoutAnimation {
                self?.configureVerticalConstraiint()
            }
        }
    }
}

// MARK: 심사용 로직
extension LoginSelectVC {
    private func checkReviewButton() {
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
                self?.configureReviewButton()
            }
        }
    }
    
    private func configureReviewButton() {
        let button = SemomunReviewButton()
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.showLoginForReview()
        }), for: .touchUpInside)
        
        self.view.addSubview(button)
        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(equalTo: self.appleLoginButton.topAnchor, constant: -16),
            button.centerXAnchor.constraint(equalTo: self.appleLoginButton.centerXAnchor)
        ])
    }
    
    private func showLoginForReview() {
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

// MARK: configure
extension LoginSelectVC {
    private func configureViewModel() {
        let networkUsecase = NetworkUsecase(network: Network())
        self.viewModel = LoginSelectVM(networkUsecase: networkUsecase, usecase: LoginSignupUsecase(networkUsecase: networkUsecase))
    }
    
    private func configureView() {
        self.cancelButton.setImageWithSVGTintColor(image: UIImage(.xOutline), color: .black)
        
        let frameView = UIView()
        frameView.translatesAutoresizingMaskIntoConstraints = false
        frameView.addSubview(self.logoImageView)
        NSLayoutConstraint.activate([
            self.logoImageView.topAnchor.constraint(equalTo: frameView.topAnchor),
            self.logoImageView.centerXAnchor.constraint(equalTo: frameView.centerXAnchor)
        ])
        frameView.addSubview(self.descriptionLabel)
        NSLayoutConstraint.activate([
            self.descriptionLabel.topAnchor.constraint(equalTo: self.logoImageView.bottomAnchor, constant: 37),
            self.descriptionLabel.leadingAnchor.constraint(equalTo: frameView.leadingAnchor),
            self.descriptionLabel.trailingAnchor.constraint(equalTo: frameView.trailingAnchor)
        ])
        frameView.addSubview(self.stackView)
        self.verticalConstraint = self.stackView.topAnchor.constraint(equalTo: self.descriptionLabel.bottomAnchor, constant: 232)
        self.verticalConstraint?.isActive = true
        NSLayoutConstraint.activate([
            self.stackView.centerXAnchor.constraint(equalTo: frameView.centerXAnchor),
            self.stackView.bottomAnchor.constraint(equalTo: frameView.bottomAnchor)
        ])
        
        self.view.addSubview(frameView)
        NSLayoutConstraint.activate([
            frameView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            frameView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }
    
    private func configureLoginWithAppleButton() -> UIButton {
        self.configureButtonAction(self.appleLoginButton, loginMethod: .apple)
        return self.appleLoginButton
    }
    
    private func configureLoginWithGoogleButton() -> UIButton {
        let button = GoogleLoginButton()
        self.configureButtonAction(button, loginMethod: .google)
        return button
    }
    
    private func configureSignupButton() -> UIButton {
        let button = SignupButton()
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.startSignup()
        }), for: .touchUpInside)
        return button
    }
    
    private func configureVerticalConstraiint() {
        if UIWindow.isLandscape {
            self.verticalConstraint?.constant = 100
        } else {
            self.verticalConstraint?.constant = 232
        }
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
            self?.startSignup()
        }
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
    
    private func configureButtonAction(_ button: UIControl, loginMethod: LoginMethod) {
        let action = UIAction { [weak self] _ in
            switch loginMethod {
            case .apple: self?.appleSignInButtonPressed()
            case .google: self?.googleSignInButtonPressed()
            }
        }
        button.addAction(action, for: .touchUpInside)
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
            self.viewModel?.login(userIDToken: .apple(token))
        default: break
        }
    }
    
    private func authorizationGoogleController(user: GIDGoogleUser) {
        user.authentication.do { authentication, error in
            guard error == nil else { return }
            guard let authentication = authentication,
                  let idToken = authentication.idToken else { return }
            self.viewModel?.login(userIDToken: .google(idToken))
        }
    }
}
// MARK: Signup
extension LoginSelectVC {
    private func startSignup() {
        // 생성 예정
        guard let nextVC = UIStoryboard(name: LoginSignupVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: LoginSignupVC.identifier) as? LoginSignupVC else { return }
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}
