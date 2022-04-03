//
//  OAuthAuthenticator.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/04/03.
//

import Foundation
import Alamofire

enum OAuthError: Error {
    case refreshTokenExpired, fail
}

/// AuthenticationCredential로 URLRequest를 서버에서 인증 가능하게(authenticate) 하며 필요한 경우 AuthenticationCredential을 재발급받는다.
class OAuthAuthenticator: Authenticator {
    
    /// 토큰을 URLRequest에 적용
    func apply(_ credential: OAuthCredential, to urlRequest: inout URLRequest) {
        guard let networkTokens = NetworkTokens() else {
            assertionFailure()
            return
        }
        urlRequest.headers.add(.authorization(bearerToken: networkTokens.accessToken))
    }
    
    /// 토큰을 재발급받고 completion에 전달
    func refresh(
        _ credential: OAuthCredential,
        for session: Session,
        completion: @escaping (Result<OAuthCredential, Error>) -> Void) {
            
            guard let token = NetworkTokens() else {
                print("refresh에 사용 가능한 토큰값 없음")
                assertionFailure()
                completion(.failure(OAuthError.fail))
                return
            }
            
            let headers: HTTPHeaders = [
                .authorization(bearerToken: token.accessToken),
                .refresh(token: token.refreshToken)]
            
            AF.request(NetworkURL.refreshToken, method: .get, headers: headers) { $0.timeoutInterval = .infinity }
                .responseDecodable(of: NetworkTokens.self) { result in
                    switch result.result {
                    case .success(let token):
                        do {
                            try token.save()
                            print("토큰 재발급 완료: \(token)")
                            let credential = OAuthCredential()
                            completion(.success(credential))
                        } catch {
                            print("토큰 저장 실패: \(error)")
                            completion(.failure(OAuthError.fail))
                        }
                    case .failure(let error):
                        print("토큰 재발급 실패: \(error)")
                        completion(.failure(OAuthError.refreshTokenExpired))
                    }
                }
        }
    
    /// URLResponse로부터 토큰이 만료되었는지 확인
    func didRequest(_ urlRequest: URLRequest,
                    with response: HTTPURLResponse,
                    failDueToAuthenticationError error: Error) -> Bool {
        return response.statusCode == 401
    }
    
    /// Refresh 작업 후 완료된 request들에 대해 새로운 토큰이 적용되었는지 확인
    func isRequest(_ urlRequest: URLRequest, authenticatedWith credential: OAuthCredential) -> Bool {
        guard let networkTokens = NetworkTokens() else {
            assertionFailure()
            return true
        }
        let bearerToken = HTTPHeader.authorization(bearerToken: networkTokens.accessToken).value
        return urlRequest.headers["Authorization"] == bearerToken
    }
}
