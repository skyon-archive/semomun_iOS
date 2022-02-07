//
//  LoginSelectVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import AuthenticationServices
import GoogleSignIn

class LoginSelectVC: UIViewController {
    
    static let identifier = "LoginSelectVC"
    static let storyboardName = "StartLogin"

    @IBOutlet weak var semomunTitle: UILabel!
    
    private let buttonWidth: CGFloat = 345
    private let buttonHeight: CGFloat = 54
    private let buttonRadius: CGFloat = 10
    private let signInConfig = GIDConfiguration.init(clientID: "688270638151-kgmitk0qq9k734nq7nh9jl6adhd00b57.apps.googleusercontent.com")
    
    private var networkUseCase: NetworkUsecase?
    private var showPopup = true
    private var signupInfo: UserInfo?
    
    private var signupInfoWritten: Bool {
        return signupInfo != nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNetwork()
        self.configureSignInAppleButton()
        self.configureSignInGoogleButton()
    }
    
    func configurePopup(isNeeded: Bool) {
        self.showPopup = isNeeded
    }
    
    func configureSignupInfo(_ signupInfo: UserInfo) {
        self.signupInfo = signupInfo
    }
}

// MARK: Configure
extension LoginSelectVC {
    private func configureNetwork() {
        let network = Network()
        self.networkUseCase = NetworkUsecase(network: network)
    }
    
    private func configureSignInAppleButton() {
        let authorizationButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        authorizationButton.layer.cornerRadius = self.buttonRadius
        
        let action = UIAction { [weak self] _ in
            self?.signInButtonAction(loginMethod: .apple)
        }
        authorizationButton.addAction(action, for: .touchUpInside)
        
        self.configureSignInWithAppleLayout(of: authorizationButton)
    }
    
    private func configureSignInGoogleButton() {
        let googleSignInButton = UIControl()
        googleSignInButton.backgroundColor = .white
        
        let buttonContent = UIView()
        buttonContent.layer.borderColor = UIColor.gray.cgColor
        buttonContent.layer.borderWidth = 1
        
        let googleIconImg = UIImage(named: "googleLogo")!
        let googleIcon = UIImageView(image: googleIconImg)
        
        let text = UILabel()
        text.text = "Google로 로그인"
        text.textColor = UIColor(.grayTextColor)
        text.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        
        googleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        buttonContent.translatesAutoresizingMaskIntoConstraints = false
        googleSignInButton.addSubview(buttonContent)
        
        NSLayoutConstraint.activate([
            buttonContent.centerXAnchor.constraint(equalTo: googleSignInButton.centerXAnchor),
            buttonContent.centerYAnchor.constraint(equalTo: googleSignInButton.centerYAnchor),
        ])
        
        googleIcon.translatesAutoresizingMaskIntoConstraints = false
        buttonContent.addSubview(googleIcon)
        
        NSLayoutConstraint.activate([
            googleIcon.widthAnchor.constraint(equalToConstant: 20),
            googleIcon.heightAnchor.constraint(equalToConstant: 20),
            googleIcon.centerYAnchor.constraint(equalTo: buttonContent.centerYAnchor),
            googleIcon.leadingAnchor.constraint(equalTo: buttonContent.leadingAnchor)
        ])
        
        text.translatesAutoresizingMaskIntoConstraints = false
        buttonContent.addSubview(text)
        
        NSLayoutConstraint.activate([
            text.leadingAnchor.constraint(equalTo: googleIcon.trailingAnchor, constant: 5),
            text.centerYAnchor.constraint(equalTo: buttonContent.centerYAnchor),
            text.trailingAnchor.constraint(equalTo: buttonContent.trailingAnchor)
        ])
        
        let action = UIAction { [weak self] _ in
            self?.signInButtonAction(loginMethod: .google)
        }
        googleSignInButton.addAction(action, for: .touchUpInside)
        
        googleSignInButton.layer.cornerRadius = self.buttonRadius
        
        self.configureSignInWithGoogleButtonLayout(of: googleSignInButton)
    }
}

// MARK: 전체 화면에서 로그인 버튼 레이아웃
extension LoginSelectVC {
    private func configureSignInWithAppleLayout(of button: UIControl) {
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: self.buttonWidth),
            button.heightAnchor.constraint(equalToConstant: self.buttonHeight),
            button.topAnchor.constraint(equalTo: self.semomunTitle.bottomAnchor, constant: 200),
            button.centerXAnchor.constraint(equalTo: self.semomunTitle.centerXAnchor)
        ])
        button.addShadow(direction: .bottom)
    }
    
    private func configureSignInWithGoogleButtonLayout(of button: UIControl) {
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: self.buttonWidth),
            button.heightAnchor.constraint(equalToConstant: self.buttonHeight),
            button.topAnchor.constraint(equalTo: self.semomunTitle.bottomAnchor, constant: 280),
            button.centerXAnchor.constraint(equalTo: self.semomunTitle.centerXAnchor)
        ])
        button.addShadow(direction: .bottom)
    }
}

// MARK: 로그인 상황별 분기처리
extension LoginSelectVC {
    private func processLogin(isExistingUser: Bool) {
        switch (self.signupInfoWritten, isExistingUser) {
        case (true, true):
            // 이미 가입한 계정으로 회원가입을 또 시도하는 상태
            self.showAlertWithOK(title: "이미 존재하는 계정입니다", text: "다른 계정으로 시도해주시기 바랍니다.")
        case (true, false):
            // 회원가입을 정상적으로 진행하는 상태
            // signupInfoWritten의 정의에 따라 항상 unwrapping 가능
            guard let signupInfo = self.signupInfo else { return }
            self.registerNewUser(with: signupInfo)
        case (false, true):
            // 로그인을 정상적으로 진행하는 상태
            self.getExistingUserInfoAndExit()
        case (false, false):
            // 회원가입 정보가 없는데 로그인을 시도하는 상태
            self.showAlertWithOK(title: "회원 정보가 없습니다", text: "회원가입을 진행해주시기 바랍니다.") {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func registerNewUser(with userInfo: UserInfo) {
        self.networkUseCase?.postUserSignup(userInfo: userInfo) { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .SUCCESS:
                    self?.getExistingUserInfoAndExit()
                case .INSPECTION:
                    self?.showAlertWithOK(title: "서버 점검중", text: "추후 다시 시도하시기 바랍니다.")
                default:
                    self?.showAlertWithOK(title: "회원가입 실패", text: "정보를 확인 후 다시 시도하시기 바랍니다.")
                }
            }
        }
    }
    
    private func getExistingUserInfoAndExit() {
        self.networkUseCase?.getUserInfo { [weak self] status, userInfo in
            DispatchQueue.main.async {
                switch status {
                case .SUCCESS:
                    guard let userInfo = userInfo else { return }
                    self?.saveAndExit(userInfo: userInfo)
                case .DECODEERROR:
                    self?.showAlertWithOK(title: "유저 정보 수신 불가", text: "최신버전으로 업데이트 후 다시 시도하시기 바랍니다.")
                case .INSPECTION:
                    self?.showAlertWithOK(title: "서버 점검중", text: "추후 다시 시도하시기 바랍니다.")
                default:
                    self?.showAlertWithOK(title: "네트워크 에러", text: "다시 시도하시기 바랍니다.")
                }
            }
        }
    }
    
    private func saveAndExit(userInfo: UserInfo) {
        CoreUsecase.createUserCoreData(userInfo: userInfo)
        UserDefaultsManager.set(to: true, forKey: UserDefaultsManager.Keys.logined)
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
        if self.showPopup {
            self.showServiceInfoView(loginMethod: loginMethod)
        } else {
            self.performLogin(loginMethod: loginMethod)
        }
    }
    
    private func showServiceInfoView(loginMethod: LoginMethod) {
        guard let serviceInfoVC = UIStoryboard(name: LoginServicePopupVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: LoginServicePopupVC.identifier) as? LoginServicePopupVC else { return }
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

// MARK: AS Protocols
extension LoginSelectVC: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                let token = appleIDCredential.identityToken // 할때마다 생성되는 token 값 (변동있음)
                
                self.checkUser(idToken: String(data: token!, encoding: .utf8)!) { [weak self] isUser in
                    self?.saveUserinKeychain(String(data: token!, encoding: .utf8)!)
                    self?.processLogin(isExistingUser: isUser)
                }
            default: break
        }
    }
    
    func authorizationGoogleController(user: GIDGoogleUser) {
        user.authentication.do { authentication, error in
            guard error == nil else{return}
            guard let authentication = authentication,
                  let idToken = authentication.idToken else { return }
            
            self.checkUser(idToken: idToken) { [weak self] isUser in
                self?.saveUserinKeychain(idToken)
                self?.processLogin(isExistingUser: isUser)
            }
        }
    }
    
    private func saveUserinKeychain(_ userIdentifier: String) {
        do {
            try KeychainItem(service: "com.skyon.semomoonService", account: KeychainItem.Items.userItentifier).saveItem(userIdentifier)
        } catch {
            print("Unable to save userIdentifier to keychain.")
        }
    }
    
    private func checkUser(idToken: String, completion: @escaping(Bool) -> Void) {
        self.networkUseCase?.postCheckUser(userToken: idToken) { result, isUser in
            switch result {
            case .SUCCESS:
                completion(isUser)
            case .DECODEERROR:
                self.showAlertWithOK(title: "수신 불가", text: "최신버전으로 업데이트 후 다시 시도하시기 바랍니다.")
            case .INSPECTION:
                self.showAlertWithOK(title: "서버 점검중", text: "추후 다시 시도하시기 바랍니다.")
            default:
                self.showAlertWithOK(title: "네트워크 통신 에러", text: "인증에 실패하였습니다. 다시 시도하시기 바랍니다.")
            }
        }
    }
}
