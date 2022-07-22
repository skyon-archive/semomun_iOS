//
//  Network.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation
import Alamofire

struct Network: NetworkFetchable {
    func request(url: String, method: HTTPMethod, tokenRequired: Bool, completion: @escaping (NetworkResult) -> Void) {
        
        let session = tokenRequired ? Session.sessionWithToken : Session.default
        //        print("\(method): \(url)")
        
        session.request(url, method: method) { $0.timeoutInterval = .infinity }
            .validate()
            .responseData { response in
                let networkResult = self.makeNetworkResult(with: response)
                completion(networkResult)
            }.resume()
    }
    
    func request<T: Encodable>(url: String, param: T, method: HTTPMethod, tokenRequired: Bool, completion: @escaping (NetworkResult) -> Void) {
        let session = tokenRequired ? Session.sessionWithToken : Session.default
        let encoder = self.getEncoder(for: method)
        //        print("\(method): \(url), \(param)")
        
        session.request(url, method: method, parameters: param, encoder: encoder)  { $0.timeoutInterval = .infinity }
            .validate()
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
            
            // Validate로 인해 status code는 200..<300
        case .success(let data):
            return NetworkResult(data: data, statusCode: statusCode, error: nil)
            
            // Validate로 인해 status code는 200..<300 제외
        case .failure(let error):
            print("Network Faile URL: \(optional: response.request?.url)")
            print("Network Fail \(statusCode) \(optional: response.request?.url)")
            if let data = response.data {
                print("Data: \(optional: String(data: data, encoding: .utf8))")
            }
            return NetworkResult(data: response.data, statusCode: statusCode, error: error.underlyingError)
        }
    }
    
    private func getEncoder(for method: HTTPMethod) -> ParameterEncoder {
        if method == .get {
            return URLEncodedFormParameterEncoder.default
        } else {
            return JSONParameterEncoder.dateformatted
        }
    }
}