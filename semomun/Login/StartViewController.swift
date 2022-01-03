//
//  StartViewController.swift
//  semomun
//
//  Created by Kang Minsang on 2021/09/19.
//

import UIKit
import AuthenticationServices
import GoogleSignIn

class StartViewController: UIViewController {
    static let identifier = "StartViewController"
    
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

extension StartViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func configureSignInAppleButton() {
        let authorizationButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        authorizationButton.addTarget(self, action: #selector(appleSignInButtonPressed), for: .touchUpInside)
        authorizationButton.cornerRadius = self.buttonRadius
        
        self.configureLayoutAppleButton(with: authorizationButton)
    }
    
    func configureSignInGoogleButton() {
        let googleSignInButton = GIDSignInButton()
        googleSignInButton.style = .wide
        googleSignInButton.colorScheme = GIDSignInButtonColorScheme.dark
        googleSignInButton.addTarget(self, action: #selector(googleSignInButtonPressed), for: .touchUpInside)
        googleSignInButton.layer.cornerRadius = self.buttonRadius
        
        self.configureLayoutGooleButton(with: googleSignInButton)
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
            print(userIdentifier)
            print(String(data: token!, encoding: .utf8)!)
            
            self.tokenSignInWithApple(idToken: String(data: token!, encoding: .utf8)!) { [weak self] isUser in
                self?.saveUserinKeychain(userIdentifier)
                if isUser {
                    self?.getUserInfo()
                } else {
                    self?.showNextVC()
                }
            }
        default: break
        }
    }
    
    func authorizationGoggleController(user: GIDGoogleUser) {
        user.authentication.do { authentication, error in
            guard error == nil else{return}
            guard let authentication = authentication,
                  let idToken = authentication.idToken else { return }
            print(user.userID!) // 모든 사용자가 같은 값인듯
            print(authentication.clientID) // 유저별 상수값
            print(idToken) // 할때마다 생성되는 token 값 (변동있음)
            
            self.tokenSignInWithGoogle(idToken: idToken) { [weak self] isUser in
                self?.saveUserinKeychain(idToken)
                if isUser {
                    self?.getUserInfo()
                } else {
                    self?.showNextVC()
                }
            }
        }
    }
}

extension StartViewController {
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
    
    func tokenSignInWithApple(idToken: String, completion: @escaping(Bool) -> Void) {
        NetworkUsecase.postCheckUser(userToken: idToken, userLoginMethod: .apple) { isUser in
            guard let isUser = isUser else {
                print("nil error")
                self.showAlertWithOK(title: "네트워크 통신 에러", text: "인증에 실패하였습니다. 다시 시도하시기 바랍니다.")
                return
            }
            completion(isUser)
        }
    }
    
    func tokenSignInWithGoogle(idToken: String, completion: @escaping(Bool) -> Void) {
        NetworkUsecase.postCheckUser(userToken: idToken, userLoginMethod: .google) { isUser in
            guard let isUser = isUser else {
                print("nil error")
                self.showAlertWithOK(title: "네트워크 통신 에러", text: "인증에 실패하였습니다. 다시 시도하시기 바랍니다.")
                return
            }
            completion(isUser)
        }
    }
    
    private func getUserInfo() {
        NetworkUsecase.getUserInfo(param: ["token": KeychainItem.currentUserIdentifier]) { [weak self] userInfo in
            guard let userInfo = userInfo else {
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
}

extension StartViewController {
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

extension StartViewController {
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
