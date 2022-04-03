//
//  Network.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation
import Alamofire

class Network: NetworkFetchable {
    private let sessionWithoutToken = Session()
    private lazy var sessionWithToken: Session = {
        guard let token = NetworkTokens() else {
            assertionFailure()
            return Session()
        }
        
        let credential = OAuthCredential(accessToken: token.accessToken, refreshToken: token.refreshToken)
        let authenticator = OAuthAuthenticator()
        let interceptor = AuthenticationInterceptor(authenticator: authenticator, credential: credential)
        
        return Session(interceptor: interceptor)
    }()
    
    func request(url: String, method: HTTPMethod, tokenRequired: Bool, completion: @escaping (NetworkResult) -> Void) {
        let session = tokenRequired ? sessionWithToken : sessionWithoutToken
        print("Network request: \(url), \(method)")
        session.request(url, method: method) { $0.timeoutInterval = .infinity }
        .validate(statusCode: [200])
        .responseData { response in
            let networkResult = self.makeNetworkResult(with: response)
            completion(networkResult)
        }.resume()
    }
    
    func request<T: Encodable>(url: String, param: T, method: HTTPMethod, tokenRequired: Bool, completion: @escaping (NetworkResult) -> Void) {
        let session = tokenRequired ? sessionWithToken : sessionWithoutToken
        print("Network request: \(url), \(method), \(param)")
        session.request(url, method: method, parameters: param)  { $0.timeoutInterval = .infinity }
        .validate(statusCode: [200])
        .responseData { response in
            let networkResult = self.makeNetworkResult(with: response)
            completion(networkResult)
        }.resume()
    }
    
    func request<T: Encodable>(url: String, param: T, method: HTTPMethod, encoder: JSONEncoder, tokenRequired: Bool, completion: @escaping (NetworkResult) -> Void) {
        let session = tokenRequired ? sessionWithToken : sessionWithoutToken
        print("Network request: \(url), \(method), \(param)")
        let parameterEncoder = JSONParameterEncoder(encoder: encoder)
        session.request(url, method: method, parameters: param, encoder: parameterEncoder)  { $0.timeoutInterval = .infinity }
        .validate(statusCode: [200])
        .responseData { response in
            let networkResult = self.makeNetworkResult(with: response)
            completion(networkResult)
        }.resume()
    }
    
    private func makeNetworkResult(with response: AFDataResponse<Data>) -> NetworkResult {
        // Status code가 없으면 data가 없음을 전제
        guard let statusCode = response.response?.statusCode else {
            print("Network Fail: No status code, \(optional: response.error)")
            return NetworkResult(data: nil, statusCode: nil, error: nil)
        }
        
        switch response.result {
            
        // Validate로 인해 status code == 200
        case .success(let data):
            return NetworkResult(data: data, statusCode: statusCode, error: nil)
            
        // Validate로 인해 status code != 200
        case .failure(let error):
            print("Network Fail: status code is \(statusCode)")
            if let data = response.data {
                print("Data: \(String(data: data, encoding: .utf8)!)")
            }
            return NetworkResult(data: response.data, statusCode: statusCode, error: error.underlyingError)
        }
    }
}
