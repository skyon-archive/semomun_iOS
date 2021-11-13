//
//  StartViewController.swift
//  StartViewController
//
//  Created by qwer on 2021/09/19.
//

import UIKit
import AuthenticationServices
import GoogleSignIn

class StartViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding{
    
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
    
    @IBAction func register(_ sender: Any) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "CertificationViewController") else { return }
        self.title = ""
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func login(_ sender: Any) {
        print("login")
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "LoginViewController") else { return }
        self.title = ""
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    
}

extension StartViewController{
    
    func setUpSignInAppleButton(){
        let authorizationButton = ASAuthorizationAppleIDButton()
        authorizationButton.addTarget(self, action: #selector(appleSignInButtonPress), for: .touchUpInside)
        authorizationButton.cornerRadius = 20
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
        if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            print("User id is \(userIdentifier) \n Full Name is \(String(describing: fullName)) \n Email id is \(String(describing: email))")
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }
    
    
}

extension StartViewController{
    func setUpSignInGoogleButton(){
        let googleSignInButton: GIDSignInButton! = GIDSignInButton()
        googleSignInButton.style = .standard
        googleSignInButton.layer.cornerRadius = 20
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
        }
    }
}
