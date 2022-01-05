//
//  StartViewController.swift
//  semomun
//
//  Created by Kang Minsang on 2021/09/19.
//

import UIKit
import AuthenticationServices
import GoogleSignIn

class LoginViewController: UIViewController {
    static let identifier = "LoginViewController"
    
    var signupInfo: UserInfo?
    
    @IBOutlet weak var semomunTitle: UILabel!
    private let buttonWidth: CGFloat = 230
    private let buttonHeight: CGFloat = 43
    private let buttonRadius: CGFloat = 8
    private let signInConfig = GIDConfiguration.init(clientID: "436503570920-07bqbk38ub6tauc97csf5uo1o2781lm1.apps.googleusercontent.com")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureSignInAppleButton()
        self.configureSignInGoogleButton()
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func configureSignInAppleButton() {
        let authorizationButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        authorizationButton.addTarget(self, action: #selector(showServiceInfoView(_:)), for: .touchUpInside)
        authorizationButton.cornerRadius = self.buttonRadius
        authorizationButton.tag = 0
        
        self.configureLayoutAppleButton(with: authorizationButton)
    }
    
    func configureSignInGoogleButton() {
        let googleSignInButton = GIDSignInButton()
        googleSignInButton.style = .wide
        googleSignInButton.colorScheme = GIDSignInButtonColorScheme.dark
        googleSignInButton.addTarget(self, action: #selector(showServiceInfoView(_:)), for: .touchUpInside)
        googleSignInButton.layer.cornerRadius = self.buttonRadius
        googleSignInButton.tag = 1
        
        self.configureLayoutGooleButton(with: googleSignInButton)
    }
    
    @objc func showServiceInfoView(_ sender: UIButton) {
        guard let serviceInfoVC = self.storyboard?.instantiateViewController(withIdentifier: ServiceInfoViewController.identifier) as? ServiceInfoViewController else { return }
        serviceInfoVC.tag = sender.tag
        serviceInfoVC.delegate = self
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
            let userIdentifier = appleIDCredential.user // 유저별 상수값
            let token = appleIDCredential.identityToken // 할때마다 생성되는 token 값 (변동있음)
            
            self.checkUser(idToken: String(data: token!, encoding: .utf8)!) { [weak self] isUser in
                self?.saveUserinKeychain(userIdentifier)
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

extension LoginViewController {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error)
    }
    
    private func saveUserinKeychain(_ userIdentifier: String) {
        do {
            try KeychainItem(service: "com.skyon.semomoonService", account: "userIdentifier").saveItem(userIdentifier)
        } catch {
            print("Unable to save userIdentifier to keychain.")
        }
    }
    
    func checkUser(idToken: String, completion: @escaping(Bool) -> Void) {
        NetworkUsecase.postCheckUser(userToken: idToken) { result, isUser in
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
    
    private func getUserInfo() {
        NetworkUsecase.getUserInfo() { [weak self] userInfo in
            guard let userInfo = userInfo,
                  let _ = userInfo.uid else {
                self?.showAlertWithOK(title: "네트워크 통신 에러", text: "회원정보를 불러오는데 실패하였습니다.")
                return
            }
            CoreUsecase.createUserCoreData(userInfo: userInfo)
            UserDefaults.standard.setValue(userInfo.favoriteCategory, forKey: "currentCategory")
            UserDefaults.standard.setValue(true, forKey: "logined")
            self?.showAlertOKWithClosure(title: "로그인 성공", text: "로그인에 성공하였습니다.", completion: { [weak self] _ in
                self?.goMainVC()
            })
        }
    }
    
    private func processLogin(with isUser: Bool) {
        if !isUser {
            if self.signupInfo == nil {
                self.showAlertWithOK(title: "회원 정보가 없습니다", text: "회원가입을 진행해주시기 바랍니다.")
            }
            // POST /register
        } else {
            if self.signupInfo != nil {
                // POST /user/self
            } else {
                self.getUserInfo()
            }
        }
    }
}

extension LoginViewController {
    private func showNextVC() {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: CertificationViewController.identifier) else { return }
        self.title = ""
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    private func goMainVC() {
        guard let mainViewController = self.storyboard?.instantiateViewController(identifier: MainViewController.identifier) else { return }
        let navigationController = UINavigationController(rootViewController: mainViewController)
        navigationController.navigationBar.tintColor = UIColor(named: SemomunColor.mainColor)
        
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
}

extension LoginViewController {
    private func configureLayoutAppleButton(with button: UIControl) {
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: self.buttonWidth-8),
            button.heightAnchor.constraint(equalToConstant: self.buttonHeight),
            button.topAnchor.constraint(equalTo: self.semomunTitle.bottomAnchor, constant: 200),
            button.centerXAnchor.constraint(equalTo: self.semomunTitle.centerXAnchor)
        ])
    }
    
    private func configureLayoutGooleButton(with button: UIControl) {
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: self.buttonWidth),
            button.heightAnchor.constraint(equalToConstant: self.buttonHeight),
            button.topAnchor.constraint(equalTo: self.semomunTitle.bottomAnchor, constant: 270),
            button.centerXAnchor.constraint(equalTo: self.semomunTitle.centerXAnchor)
        ])
    }
}

extension LoginViewController: RegisgerServiceSelectable {
    func appleLogin() {
        self.appleSignInButtonPressed()
    }
    
    func googleLogin() {
        self.googleSignInButtonPressed()
    }
}
