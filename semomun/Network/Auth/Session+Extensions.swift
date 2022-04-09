//
//  AuthenticatorInterceptor.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/04/07.
//

import Alamofire

extension Session {
    static var sessionWithToken: Session {
        if let _sessionWithToken = self._sessionWithToken {
            return _sessionWithToken
        } else {
            guard let token = NetworkTokens() else {
                assertionFailure()
                return Session()
            }
            
            print("token: \(token.accessToken)")
            
            let credential = OAuthCredential(accessToken: token.accessToken, refreshToken: token.refreshToken)
            let authenticator = OAuthAuthenticator()
            let interceptor = AuthenticationInterceptor(authenticator: authenticator, credential: credential)
            
            let session = Session(interceptor: interceptor)
            self._sessionWithToken = session
            
            return session
        }
    }
    
    static func clearSession() {
        self._sessionWithToken = nil
    }
    
    private static var _sessionWithToken: Session?
}
