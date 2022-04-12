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
        } else if let token = NetworkTokens() {
            print("Access token: \(token.accessToken)")
            let session = self.createSessionWithToken(token)
            self._sessionWithToken = session
            return session
        } else {
            assertionFailure()
            return Session()
        }
    }
    
    static func clearSession() {
        self._sessionWithToken = nil
    }
    
    private static var _sessionWithToken: Session?
    
    private static func createSessionWithToken(_ token: NetworkTokens) -> Session {
        let credential = OAuthCredential(accessToken: token.accessToken, refreshToken: token.refreshToken)
        let interceptor = AuthenticationInterceptor(authenticator: OAuthAuthenticator(), credential: credential)
        
        return Session(interceptor: interceptor)
    }
}
