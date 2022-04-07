//
//  AuthenticatorInterceptor.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/04/07.
//

import Alamofire

extension Session {
    static var sessionWithToken: Session = {
        guard let token = NetworkTokens() else {
            assertionFailure()
            return Session()
        }
        
        print("token: \(token.accessToken)")
        
        let credential = OAuthCredential(accessToken: token.accessToken, refreshToken: token.refreshToken)
        let authenticator = OAuthAuthenticator()
        let interceptor = AuthenticationInterceptor(authenticator: authenticator, credential: credential)
        
        return Session(interceptor: interceptor)
    }()
}
