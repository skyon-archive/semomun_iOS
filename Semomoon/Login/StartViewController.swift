//
//  StartViewController.swift
//  StartViewController
//
//  Created by qwer on 2021/09/19.
//

import UIKit
import AuthenticationServices
import GoogleSignIn

class StartViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    static let identifier = "StartViewController"
    
    let signInConfig = GIDConfiguration.init(clientID: "436503570920-07bqbk38ub6tauc97csf5uo1o2781lm1.apps.googleusercontent.com")
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    

    @IBOutlet weak var signInButtonStack: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSignInAppleButton()
        setUpSignInGoogleButton()
        // Do any additional setup after loading the view.
    }
    
}

extension StartViewController{
    
    func showNextVC() {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: CertificationViewController.identifier) else { return }
        self.title = ""
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func setUpSignInAppleButton(){
        let authorizationButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        authorizationButton.translatesAutoresizingMaskIntoConstraints = false
        authorizationButton.widthAnchor.constraint(equalToConstant: 450).isActive = true
        authorizationButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        authorizationButton.addTarget(self, action: #selector(appleSignInButtonPress), for: .touchUpInside)
        authorizationButton.cornerRadius = 8
        //Add button on some view or stack
        self.signInButtonStack.addArrangedSubview(authorizationButton) // have to divide the stack view of signing in and signing out
    }
    
    func setUpSignUpAppleButton(){
        let authorizationButton = ASAuthorizationAppleIDButton()
        authorizationButton.addTarget(self, action:#selector(appleSignUpButtonPress), for: .touchUpInside)
        authorizationButton.cornerRadius = 20
        self.signInButtonStack.addArrangedSubview(authorizationButton)
    }

    @objc func appleSignInButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @objc func appleSignUpButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential{
        case let appleIDCredential  as  ASAuthorizationAppleIDCredential :
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
//            print("User id is \(userIdentifier) \n Full Name is \(String(describing: fullName)) \n Email id is \(String(describing: email))")
            
            self.saveUserinKeychain(userIdentifier)
            
            showNextVC()
            
        default:
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }
    
    private func saveUserinKeychain(_ userIdentifier: String){
        do{
            try KeychainItem(service: "com.skyon.semomoonService", account: "userIdentifier").saveItem(userIdentifier)
        } catch {
            print("Unable to save userIdentifier to keychain.")
        }
    }
    
}

extension StartViewController{
    func setUpSignInGoogleButton(){
        let googleSignInButton: GIDSignInButton! = GIDSignInButton()
        googleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        googleSignInButton.widthAnchor.constraint(equalToConstant: 500).isActive = true
        googleSignInButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        googleSignInButton.colorScheme = GIDSignInButtonColorScheme.dark
        googleSignInButton.layer.cornerRadius = 8
        googleSignInButton.addTarget(self, action: #selector(googleSignInButtonPress), for: .touchUpInside)
        self.signInButtonStack.addArrangedSubview(googleSignInButton)
    }
    
    @IBAction func googleSignInButtonPress(sender: Any){
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
            guard error == nil else { return }
            guard let user = user else { return }
            // If sign in succeeded, display the app's main content View.
            let emailAddress = user.profile?.email
            
            let fullName = user.profile?.name
            let givenName = user.profile?.givenName
            let familyName = user.profile?.familyName
            
            let profilePicUrl = user.profile?.imageURL(withDimension: 320)

            
            
            user.authentication.do { authentication, error in
                guard error == nil else{return}
                guard let authentication = authentication else {return}
                
                let idToken = authentication.idToken
                self.tokenSignIn(idToken: idToken!)
                self.saveUserinKeychain(idToken!)
//                print("User id is \(idToken) \n Full Name is \(String(describing: fullName)) \n Email id is \(String(describing: emailAddress))")
            }
            
            self.showNextVC()
        }
    }
}

extension StartViewController{
    func tokenSignIn(idToken: String){
        guard let authData = try? JSONEncoder().encode(["idToken" : idToken]) else {return}
        let url = URL(string: "https://yourbackend.example.com/tokensignin")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(("application/json"), forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.uploadTask(with: request, from: authData) {data, response, error in }
        task.resume()
        NetworkUsecase.postCheckUser(userToken: idToken, isGoogle: true, isApple: false) { data in
            guard let data = data else {
                print("login result is nil")
                return
            }
            print(String(data: data, encoding: .utf8))
        }
    }
}
