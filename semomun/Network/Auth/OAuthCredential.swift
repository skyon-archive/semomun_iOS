//
//  OAuthCredential.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/04/03.
//

import Foundation
import Alamofire

/// URLRequest를 서버에서 인증 가능하게(authenticate) 만든다.
struct OAuthCredential: AuthenticationCredential {
    let accessToken: String
    let refreshToken: String
    
    let requiresRefresh = false
}
