//
//  LoginSelectVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import AuthenticationServices
import GoogleSignIn

final class LoginSelectVC: UIViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNetwork()
        self.configureSignInWithAppleButton()
        self.configureSignInWithGoogleButton()
    }
}

// MARK: Public configures
extension LoginSelectVC {
    func configurePopup(isNeeded: Bool) {
        self.showPopup = isNeeded
    }
    
    func configureSignupInfo(_ signupInfo: UserInfo) {
        self.signupInfo = signupInfo
    }
}

// MARK: Private configures
extension LoginSelectVC {
    private func configureNetwork() {
        let network = Network()
        self.networkUseCase = NetworkUsecase(network: network)
    }
    
    private func configureSignInWithAppleButton() {
        let authorizationButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        authorizationButton.layer.cornerRadius = self.buttonRadius
        let action = UIAction { [weak self] _ in
            self?.signInButtonAction(loginMethod: .apple)
        }
        authorizationButton.addAction(action, for: .touchUpInside)
        self.configureSignInButtonLayout(authorizationButton, verticalSpaceToSemomunTitle: 200)
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
        let googleIconImg = UIImage(named: SemomunImage.googleLogo) ?? UIImage()
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
        text.text = "Google로 로그인"
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
        
        self.configureSignInButtonLayout(signInWithGoogleButton, verticalSpaceToSemomunTitle: 280)
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

// MARK: 로그인 버튼 액션
extension LoginSelectVC {
    private enum LoginMethod {
        case apple, google
    }
   
    /// 로그인 버튼이 탭 되었을 때 실행되는 함수
    private func signInButtonAction(loginMethod: LoginMethod) {
        if self.showPopup {
            self.showServiceInfoView(loginMethod: loginMethod)
        } else {
            self.performActualLogin(loginMethod: loginMethod)
        }
    }
    
    private func showServiceInfoView(loginMethod: LoginMethod) {
        guard let serviceInfoVC = UIStoryboard(name: LoginServicePopupVC.storyboardName, bundle: nil)
                .instantiateViewController(withIdentifier: LoginServicePopupVC.identifier) as? LoginServicePopupVC else { return }
        serviceInfoVC.configureConfirmAction { [weak self] in
            self?.performActualLogin(loginMethod: loginMethod)
        }
        self.present(serviceInfoVC, animated: true, completion: nil)
    }
    
    private func performActualLogin(loginMethod: LoginMethod) {
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

// MARK: 로그인 시도 후 상황별 분기처리
extension LoginSelectVC {
    private var signupInfoConfigured: Bool {
        return signupInfo != nil
    }
    
    /// 로그인 절차 이후 반환받은 isExistinguser 값으로 분기처리 진행
    private func processLogin(isExistingUser: Bool) {
        switch (self.signupInfoConfigured, isExistingUser) {
        case (true, true): // 이미 가입한 계정으로 회원가입을 또 시도하는 상태
            let alertController = UIAlertController(title: "이미 존재하는 계정", message: "방금 입력하신 정보로 계정 정보를 덮어씌울까요?", preferredStyle: .alert)
            let alertActions = [
                UIAlertAction(title: "취소", style: .cancel),
                UIAlertAction(title: "덮어씌우기", style: .default) { [weak self] _ in
                    guard let signupInfo = self?.signupInfo else { return }
                    self?.registerUser(with: signupInfo)
                }
            ]
            alertActions.forEach { alertController.addAction($0) }
            self.present(alertController, animated: true)
        case (true, false): // 회원가입을 정상적으로 진행하는 상태
            guard let signupInfo = self.signupInfo else { return } // signupInfoWritten의 정의에 따라 항상 unwrapping 가능
            self.registerUser(with: signupInfo)
        case (false, true): // 로그인을 정상적으로 진행하는 상태
            self.fetchUserInfoAndDismiss()
        case (false, false): // 회원가입 정보가 없는데 로그인을 시도하는 상태
            self.showAlertWithOK(title: "회원 정보가 없습니다", text: "회원가입을 진행해주시기 바랍니다.") {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func registerUser(with userInfo: UserInfo) {
        self.networkUseCase?.postUserSignup(userInfo: userInfo) { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .SUCCESS:
                    self?.fetchUserInfoAndDismiss()
                case .INSPECTION:
                    self?.showAlertWithOK(title: "서버 점검중", text: "추후 다시 시도하시기 바랍니다.")
                default:
                    self?.showAlertWithOK(title: "회원가입 실패", text: "정보를 확인 후 다시 시도하시기 바랍니다.")
                }
            }
        }
    }
    
    private func fetchUserInfoAndDismiss() {
        self.networkUseCase?.getUserInfo { [weak self] status, userInfo in
            DispatchQueue.main.async {
                switch status {
                case .SUCCESS:
                    guard let userInfo = userInfo else { return }
                    self?.saveAndDismissView(userInfo: userInfo)
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
    
    private func saveAndDismissView(userInfo: UserInfo) {
        CoreUsecase.createUserCoreData(userInfo: userInfo)
        UserDefaultsManager.set(to: true, forKey: UserDefaultsManager.Keys.logined)
        self.showAlertWithOK(title: "로그인 완료", text: "로그인에 성공하였습니다.") { [weak self] in
            self?.presentingViewController?.dismiss(animated: true, completion: nil)
            NotificationCenter.default.post(name: .logined, object: nil)
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
            guard error == nil else { return }
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
