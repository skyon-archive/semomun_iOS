//
//  NetworkTokenController.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/03/03.
//

import Foundation
import Alamofire

enum NetworkTokenControllerError: Error {
    case tokenExpired
}

struct NetworkTokenController: RequestInterceptor {
    /// 네트워크 요청 전 urlRequest에 관한 처리를 가로채서 적용
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Swift.Result<URLRequest, Error>) -> Void) {
        // TODO: 토큰값이 필요한 요청에 대해서만 토큰을 추가하도록 수정하기
        guard urlRequest.url?.absoluteString.hasPrefix(NetworkURL.base) == true,
              let authToken = try? KeychainItem(account: .accessToken).readItem() else {
                  completion(.success(urlRequest))
                  return
              }
        var urlRequest = urlRequest
        urlRequest.setValue("Bearer " + authToken, forHTTPHeaderField: "Authorization")
        
        completion(.success(urlRequest))
    }
    
    ///  네트워크 요청 결과로 Error가 발생한 경우, 이를 처리한 다음 Error가 발생한 요청를 재시도할지 판단
    ///  - 401 status code가 반환되었을 때 토큰 재발급 시도
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 else {
            completion(.doNotRetry)
            return
        }
        
        guard let token = NetworkTokens() else {
            print("refresh에 사용 가능한 토큰값 없음")
            completion(.doNotRetry)
            return
        }
        
        self.requestTokenRefresh(using: token) { result in
            switch result.result {
            case .success(let token):
                do {
                    try token.save()
                    print("토큰 재발급 완료: \(token)")
                    completion(.retry)
                } catch {
                    print("토큰 저장 실패: \(error)")
                    completion(.doNotRetryWithError(error))
                }
            case .failure(let error):
                print("토큰 재발급 실패: \(error)")
                completion(.doNotRetryWithError(NetworkTokenControllerError.tokenExpired))
            }
        }
    }
    
    /// 전달받은 토큰값을 사용해 토큰 갱신을 서버로 요청
    private func requestTokenRefresh(using networkTokens: NetworkTokens, completion: @escaping (AFDataResponse<NetworkTokens>) -> Void) {
        let headers: HTTPHeaders = [.authorization(bearerToken: networkTokens.accessToken), .refresh(token: networkTokens.refreshToken)]
        
        AF.request(NetworkURL.refreshToken, method: .get, headers: headers) { $0.timeoutInterval = .infinity }
        .responseDecodable(of: NetworkTokens.self) { requestResult in
            completion(requestResult)
        }
    }
}
