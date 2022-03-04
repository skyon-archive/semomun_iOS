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
    
    func get(url: String, completion: @escaping (NetworkResult<String>) -> Void) {
        self.networkImplNoParam(url: url, method: .get, completion: completion)
    }
    
    func put(url: String, completion: @escaping (NetworkResult<String>) -> Void) {
        self.networkImplNoParam(url: url, method: .put, completion: completion)
    }
    
    func get<T: Encodable>(url: String, param: T, completion: @escaping (NetworkResult<String>) -> Void) {
        self.networkImpl(url: url, method: .get, param: param, completion: completion)
    }
    
    func post<T: Encodable>(url: String, param: T, completion: @escaping (NetworkResult<String>) -> Void) {
        self.networkImpl(url: url, method: .post, param: param, completion: completion)
    }
    
    func put<T: Encodable>(url: String, param: T, completion: @escaping (NetworkResult<String>) -> Void) {
        self.networkImpl(url: url, method: .put, param: param, completion: completion)
    }
    
    func get<U: Decodable>(url: String, completion: @escaping (NetworkResult<U>) -> Void) {
        self.networkImplNoParam(url: url, method: .get, completion: completion)
    }
    
    private func networkImplNoParam<T: Decodable>(url: String, method: HTTPMethod, completion: @escaping (NetworkResult<T>) -> Void) {
        print("Network request: \(url), \(method)")
        session.request(url, method: method)  { $0.timeoutInterval = .infinity }
        .responseDecodable(of: T.self) { response in
            let networkResult = self.makeNetworkResult(with: response)
            completion(networkResult)
        }.resume()
    }
    
    private func networkImpl<T: Encodable, U:Decodable>(url: String, method: HTTPMethod, param: T, completion: @escaping (NetworkResult<U>) -> Void) {
        print("Network request: \(url), \(method), \(param)")
        session.request(url, method: method, parameters: param)  { $0.timeoutInterval = .infinity }
        .responseDecodable(of: U.self) { response in
            let networkResult = self.makeNetworkResult(with: response)
            completion(networkResult)
        }.resume()
    }
    
    
    private func makeNetworkResult<T>(with response: DataResponse<T, AFError>) -> NetworkResult<T> {
        guard let statusCode = response.response?.statusCode else {
            print("Fail: no statusCode")
            return NetworkResult<T>(status: .FAIL, data: nil, statusCode: -1, encodedData: nil)
        }
        guard let data = response.data else {
            print("Fail: no data, statusCode: \(statusCode)")
            return NetworkResult<T>(status: .FAIL, data: nil, statusCode: statusCode, encodedData: nil)
        }
        guard statusCode == 200 else {
            print("Error statusCode: \(statusCode)")
            print("\(optional: String(data: data, encoding: .utf8))")
            return NetworkResult<T>(status: .ERROR, data: data, statusCode: statusCode, encodedData: nil)
        }
        return NetworkResult<T>(status: .SUCCESS, data: data, statusCode: statusCode, encodedData: nil)
    }
}
