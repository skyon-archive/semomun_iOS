//
//  OAuthCredential.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/04/03.
//

import Foundation
import Alamofire

/// URLRequest를 서버에서 인증 가능하게(authenticate) 하기 위해 사용됨.
struct OAuthCredential: AuthenticationCredential {
    let accessToken: String
    let refreshToken: String
    
    /// 해당 객체가 refresh되야하는지 여부를 확인.
    let requiresRefresh = false
}
