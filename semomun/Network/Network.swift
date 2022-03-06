//
//  Network.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation
import Alamofire

struct Network: NetworkFetchable {
    private let session = Session(interceptor: NetworkTokenController())
    
    func request(url: String, method: HTTPMethod, completion: @escaping (NetworkResult) -> Void) {
        print("Network request: \(url), \(method)")
        session.request(url, method: method)  { $0.timeoutInterval = .infinity }
        .responseData { response in
            let networkResult = self.makeNetworkResult(with: response)
            completion(networkResult)
        }.resume()
    }

    func request<T: Encodable>(url: String, param: T, method: HTTPMethod, completion: @escaping (NetworkResult) -> Void) {
        print("Network request: \(url), \(method), \(param)")
        session.request(url, method: method, parameters: param)  { $0.timeoutInterval = .infinity }
        .responseData { response in
            let networkResult = self.makeNetworkResult(with: response)
            completion(networkResult)
        }.resume()
    }
    
    private func makeNetworkResult(with response: DataResponse<Data, AFError>) -> NetworkResult {
        guard let statusCode = response.response?.statusCode else {
            print("Network Fail: no statusCode")
            return NetworkResult(data: nil, statusCode: nil)
        }
        guard let data = response.data else {
            print("Network Fail: no data, statusCode \(statusCode)")
            return NetworkResult(data: nil, statusCode: statusCode)
        }
        guard statusCode == 200 else {
            print("Network Error: statusCode \(statusCode)")
            print("data: \(optional: String(data: data, encoding: .utf8))")
            return NetworkResult(data: data, statusCode: statusCode)
        }
        return NetworkResult(data: data, statusCode: statusCode)
    }
}
