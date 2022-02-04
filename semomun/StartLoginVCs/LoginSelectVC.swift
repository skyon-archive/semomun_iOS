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
    
    var signupInfo: UserInfo?

    @IBOutlet weak var semomunTitle: UILabel!
    private let buttonWidth: CGFloat = 345
    private let buttonHeight: CGFloat = 54
    private let buttonRadius: CGFloat = 10
    private let signInConfig = GIDConfiguration.init(clientID: "688270638151-kgmitk0qq9k734nq7nh9jl6adhd00b57.apps.googleusercontent.com")
    private var networkUseCase: NetworkUsecase?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNetwork()
        self.configureSignInAppleButton()
        self.configureSignInGoogleButton()
    }
    
    private func configureNetwork() {
        let network = Network()
        self.networkUseCase = NetworkUsecase(network: network)
    }
}

extension LoginSelectVC: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private func configureSignInAppleButton() {
        let authorizationButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        authorizationButton.addTarget(self, action: #selector(showServiceInfoView(_:)), for: .touchUpInside)
        authorizationButton.layer.cornerRadius = self.buttonRadius
        authorizationButton.tag = 0
        self.configureLayoutAppleButton(with: authorizationButton)
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
        
        googleSignInButton.addTarget(self, action: #selector(showServiceInfoView(_:)), for: .touchUpInside)
        googleSignInButton.layer.cornerRadius = self.buttonRadius
        googleSignInButton.tag = 1
        
        self.configureLayoutGooleButton(with: googleSignInButton)
    }
    
    @objc func showServiceInfoView(_ sender: UIButton) {
        guard let serviceInfoVC = UIStoryboard(name: LoginServicePopupVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: LoginServicePopupVC.identifier) as? LoginServicePopupVC else { return }
        serviceInfoVC.tag = sender.tag
        serviceInfoVC.delegate = self
        serviceInfoVC.isSignin = self.signupInfo != nil ? true : false
        self.present(serviceInfoVC, animated: true, completion: nil)
    }

    @objc func appleSignInButtonPressed() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @objc func googleSignInButtonPressed() {
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
            guard error == nil else { return }
            guard let user = user else { return }
            self.authorizationGoggleController(user: user)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let token = appleIDCredential.identityToken // 할때마다 생성되는 token 값 (변동있음)
            
            self.checkUser(idToken: String(data: token!, encoding: .utf8)!) { [weak self] isUser in
                self?.saveUserinKeychain(String(data: token!, encoding: .utf8)!)
                self?.processLogin(with: isUser)
            }
        default: break
        }
    }
    
    func authorizationGoggleController(user: GIDGoogleUser) {
        user.authentication.do { authentication, error in
            guard error == nil else{return}
            guard let authentication = authentication,
                  let idToken = authentication.idToken else { return }
            
            self.checkUser(idToken: idToken) { [weak self] isUser in
                self?.saveUserinKeychain(idToken)
                self?.processLogin(with: isUser)
            }
        }
    }
}

extension LoginSelectVC {
    private func processLogin(with isUser: Bool) {
        if !isUser {
            if self.signupInfo == nil {
                self.showAlertWithOK(title: "회원 정보가 없습니다", text: "회원가입을 진행해주시기 바랍니다.")
            }
            self.signupInfo?.configureNickname(to: nil)
            self.signupInfo?.configureName(to: nil)
            self.signupInfo?.configurePhone(to: nil)
            self.registerUser()
        } else {
            if self.signupInfo != nil {
                self.getUserInfoByUser()
            } else {
                self.getUserInfo()
            }
        }
    }
    
    func checkUser(idToken: String, completion: @escaping(Bool) -> Void) {
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
    
    private func registerUser() {
        guard let userInfo = self.signupInfo else { return }
        self.networkUseCase?.postUserSignup(userInfo: userInfo) { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .SUCCESS:
                    self?.getUserInfo()
                case .INSPECTION:
                    self?.showAlertWithOK(title: "서버 점검중", text: "추후 다시 시도하시기 바랍니다.")
                default:
                    self?.showAlertWithOK(title: "회원가입 실패", text: "정보를 확인 후 다시 시도하시기 바랍니다.")
                }
            }
        }
    }
    
    private func getUserInfo() {
        self.networkUseCase?.getUserInfo() { [weak self] status, userInfo in
            DispatchQueue.main.async {
                switch status {
                case .SUCCESS:
                    self?.saveUserInfo(to: userInfo)
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
    
    private func getUserInfoByUser() {
        self.networkUseCase?.getUserInfo() { [weak self] status, userInfo in
            DispatchQueue.main.async {
                switch status {
                case .SUCCESS:
                    guard let uid = userInfo?.uid else {
                        print("uid Error")
                        self?.showAlertWithOK(title: "유저 정보 수신 불가", text: "")
                        return
                    }
                    self?.signupInfo?.configureUid(to: uid)
                    self?.signupInfo?.configureNickname(to: userInfo?.nickName)
                    self?.signupInfo?.configureName(to: userInfo?.name)
                    self?.signupInfo?.configurePhone(to: userInfo?.phone)
                    self?.updateUserInfo()
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
    
    private func updateUserInfo() {
        CoreUsecase.createUserCoreData(userInfo: self.signupInfo)
        guard let coreUserInfo = CoreUsecase.fetchUserInfo() else {
            self.showAlertWithOK(title: "CoreData 에러", text: "사용자 정보를 읽을 수 없습니다.")
            return
        }
        print("Core: \(coreUserInfo)")
        
        self.networkUseCase?.putUserInfoUpdate(userInfo: coreUserInfo) { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .SUCCESS:
                    self?.saveUserInfo(to: self?.signupInfo)
                case .INSPECTION:
                    self?.showAlertWithOK(title: "서버 점검중", text: "추후 다시 시도하시기 바랍니다.")
                default:
                    self?.showAlertWithOK(title: "네트워크 에러", text: "사용자 정보 업데이트에 실패하였습니다.")
                }
            }
        }
    }
    
    private func saveUserInfo(to userInfo: UserInfo?) {
        CoreUsecase.createUserCoreData(userInfo: userInfo)
        UserDefaultsManager.set(to: true, forKey: UserDefaultsManager.Keys.logined)
        self.showAlertWithOK(title: "로그인 성공", text: "로그인에 성공하였습니다.", completion: { [weak self] in
            self?.presentingViewController?.dismiss(animated: true, completion: nil)
            NotificationCenter.default.post(name: .logined, object: nil)
        })
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error)
    }
    
    private func saveUserinKeychain(_ userIdentifier: String) {
        do {
            try KeychainItem(service: "com.skyon.semomoonService", account: KeychainItem.Items.userItentifier).saveItem(userIdentifier)
        } catch {
            print("Unable to save userIdentifier to keychain.")
        }
    }
}

extension LoginSelectVC {
    private func showNextVC() {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: CertificationViewController.identifier) else { return }
        self.title = ""
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    private func goMainVC() {
        guard let mainViewController = self.storyboard?.instantiateViewController(identifier: MainViewController.identifier) else { return }
        let navigationController = UINavigationController(rootViewController: mainViewController)
        navigationController.navigationBar.tintColor = UIColor(.mainColor)
        
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
}

extension LoginSelectVC {
    private func configureLayoutAppleButton(with button: UIControl) {
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
    
    private func configureLayoutGooleButton(with button: UIControl) {
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

extension LoginSelectVC: RegisgerServiceSelectable {
    func appleLogin() {
        self.appleSignInButtonPressed()
    }
    
    func googleLogin() {
        self.googleSignInButtonPressed()
    }
}

