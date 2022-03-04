//
//  NetworkTokenController.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/03/03.
//

import Foundation
import Alamofire

struct NetworkTokenController: RequestInterceptor {
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Swift.Result<URLRequest, Error>) -> Void) {
        guard urlRequest.url?.absoluteString.hasPrefix(NetworkURL.base) == true,
              let authToken = try? KeychainItem(account: .accessToken).readItem() else {
                  completion(.success(urlRequest))
                  return
              }
        var urlRequest = urlRequest
        urlRequest.setValue("Bearer " + authToken, forHTTPHeaderField: "Authorization")
        completion(.success(urlRequest))
    }
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 else {
            completion(.doNotRetry)
            return
        }
        print("토큰 재발급 시작")
        self.refreshToken { result in
            switch result.result {
            case .success(let token):
                do {
                    try token.save()
                    dump(token)
                    print("토큰 재발급 완료")
                    completion(.retry)
                } catch {
                    print(error)
                    completion(.doNotRetryWithError(error))
                }
            case .failure(let error):
                print(error)
                completion(.doNotRetryWithError(error))
            }
        }
    }
    private func refreshToken(completion: @escaping (DataResponse<NetworkTokens, AFError>) -> Void) {
        guard let token = NetworkTokens() else {
            print("refresh에 사용 가능한 토큰값 없음")
            return
        }
        print(token)
        let headers: HTTPHeaders = [.authorization(bearerToken: token.accessToken), .refresh(token.refreshToken)]
        AF.request(NetworkURL.refreshToken, method: .get, headers: headers) { $0.timeoutInterval = .infinity }
        .responseDecodable(of: NetworkTokens.self) { requestResult in
            completion(requestResult)
        }
    }
}
