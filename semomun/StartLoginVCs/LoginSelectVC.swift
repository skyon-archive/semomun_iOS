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
            self.showAlertWithOK(title: "회원 정보가 없습니다", text: "회원가입을 진행해주시기 바랍니다.")
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

// 이미 존재하는 계정을 사용한 회원가입에 대한 처리가 필요
//  private func getUserInfoByUser() {
//        self.networkUseCase?.getUserInfo { [weak self] status, userInfo in
//            DispatchQueue.main.async {
//                switch status {
//                case .SUCCESS:
//                    guard let uid = userInfo?.uid else {
//                        print("uid Error")
//                        self?.showAlertWithOK(title: "유저 정보 수신 불가", text: "")
//                        return
//                    }
//                    guard let signupInfo = self?.signupInfo else { return }
//                    signupInfo.configureUid(to: uid)
//                    signupInfo.configureNickname(to: userInfo?.nickName)
//                    signupInfo.configureName(to: userInfo?.name)
//                    signupInfo.configurePhone(to: userInfo?.phone)
//                    self?.updateUserInfo(using: signupInfo)
//                case .DECODEERROR:
//                    self?.showAlertWithOK(title: "유저 정보 수신 불가", text: "최신버전으로 업데이트 후 다시 시도하시기 바랍니다.")
//                case .INSPECTION:
//                    self?.showAlertWithOK(title: "서버 점검중", text: "추후 다시 시도하시기 바랍니다.")
//                default:
//                    self?.showAlertWithOK(title: "네트워크 에러", text: "다시 시도하시기 바랍니다.")
//                }
//            }
//        }
//    }
//
//    private func updateUserInfo(using signupInfo: UserInfo) {
//        CoreUsecase.createUserCoreData(userInfo: signupInfo)
//        guard let coreUserInfo = CoreUsecase.fetchUserInfo() else {
//            self.showAlertWithOK(title: "CoreData 에러", text: "사용자 정보를 읽을 수 없습니다.")
//            return
//        }
//        print("Core: \(coreUserInfo)")
//        self.networkUseCase?.putUserInfoUpdate(userInfo: coreUserInfo) { [weak self] status in
//            DispatchQueue.main.async {
//                switch status {
//                case .SUCCESS:
//                    self?.saveAndExit(userInfo: signupInfo)
//                case .INSPECTION:
//                    self?.showAlertWithOK(title: "서버 점검중", text: "추후 다시 시도하시기 바랍니다.")
//                default:
//                    self?.showAlertWithOK(title: "네트워크 에러", text: "사용자 정보 업데이트에 실패하였습니다.")
//                }
//            }
//        }
//    }
}
// MARK: Apple, Google로 로그인 구성
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

extension LoginSelectVC: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    private func configureNetwork() {
        let network = Network()
        self.networkUseCase = NetworkUsecase(network: network)
    }
    
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
    
    @objc private func showServiceInfoView(_ sender: UIButton) {
        guard let viewControllers = self.navigationController?.viewControllers else { return }
        guard let parent = viewControllers.count > 1 ? viewControllers[viewControllers.count - 2] : nil else { return }
        if parent is LoginStartVC {
            if sender.tag == 0 {
                self.appleLogin()
            } else {
                self.googleLogin()
            }
        } else {
            guard let serviceInfoVC = UIStoryboard(name: LoginServicePopupVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: LoginServicePopupVC.identifier) as? LoginServicePopupVC else { return }
            serviceInfoVC.tag = sender.tag
            serviceInfoVC.delegate = self
            self.present(serviceInfoVC, animated: true, completion: nil)
        }
    }

    @objc private func appleSignInButtonPressed() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @objc private func googleSignInButtonPressed() {
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
                    self?.processLogin(isExistingUser: isUser)
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
