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
    
    func get(url: String, completion: @escaping (NetworkResult) -> Void) {
        self.networkImplNoParam(url: url, method: .get, completion: completion)
    }
    
    func post(url: String, completion: @escaping (NetworkResult) -> Void) {
        self.networkImplNoParam(url: url, method: .post, completion: completion)
    }
    
    func put(url: String, completion: @escaping (NetworkResult) -> Void) {
        self.networkImplNoParam(url: url, method: .put, completion: completion)
    }
    
    func get<T: Encodable>(url: String, param: T, completion: @escaping (NetworkResult) -> Void) {
        self.networkImpl(url: url, method: .get, param: param, completion: completion)
    }
    
    func post<T: Encodable>(url: String, param: T, completion: @escaping (NetworkResult) -> Void) {
        self.networkImpl(url: url, method: .post, param: param, completion: completion)
    }
    
    func put<T: Encodable>(url: String, param: T, completion: @escaping (NetworkResult) -> Void) {
        self.networkImpl(url: url, method: .put, param: param, completion: completion)
    }
    
    private func networkImplNoParam(url: String, method: HTTPMethod, completion: @escaping (NetworkResult) -> Void) {
        print("Network request: \(url), \(method)")
        session.request(url, method: method)  { $0.timeoutInterval = .infinity }
        .responseData { response in
            let networkResult = self.makeNetworkResult(with: response)
            completion(networkResult)
        }.resume()
    }
    
    private func networkImpl<T: Encodable>(url: String, method: HTTPMethod, param: T, completion: @escaping (NetworkResult) -> Void) {
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
