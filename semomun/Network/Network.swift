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
    
    func get<T: Encodable>(url: String, param: T?, completion: @escaping (NetworkResult) -> Void) {
        print("\(url), \(optional: param)")
        session.request(url, method: .get, parameters: param) { $0.timeoutInterval = .infinity }
        .responseDecodable(of: String.self) { response in
            self.toRequestResult(with: response, completion: completion)
        }.resume()
    }
    
    func get(url: String, completion: @escaping (NetworkResult) -> Void) {
        session.request(url, method: .post)  { $0.timeoutInterval = .infinity }
        .responseDecodable(of: String.self) { response in
            self.toRequestResult(with: response, completion: completion)
        }.resume()
    }
    
    func post<T: Encodable>(url: String, param: T, completion: @escaping (NetworkResult) -> Void) {
        print(url, param)
        session.request(url, method: .post, parameters: param)  { $0.timeoutInterval = .infinity }
        .responseDecodable(of: String.self) { response in
            self.toRequestResult(with: response, completion: completion)
        }.resume()
    }
    
    func put<T: Encodable>(url: String, param: T, completion: @escaping (NetworkResult) -> Void) {
        print(url, param)
        session.request(url, method: .put, parameters: param)  { $0.timeoutInterval = .infinity }
        .responseDecodable(of: String.self) { response in
            self.toRequestResult(with: response, completion: completion)
        }.resume()
    }
    
    private func toRequestResult(with response: DataResponse<String, AFError>, completion: @escaping (NetworkResult) -> Void) {
        guard let statusCode = response.response?.statusCode else {
            print("Fail: no statusCode")
            completion(NetworkResult(status: .FAIL, data: nil, statusCode: -1))
            return
        }
        
        guard let data = response.data else {
            print("Fail: no data, statusCode: \(statusCode)")
            completion(NetworkResult(status: .FAIL, data: nil, statusCode: statusCode))
            return
        }
        
        guard statusCode == 200 else {
            print("Error statusCode: \(statusCode)")
            print(String(data: data, encoding: .utf8)!)
            completion(NetworkResult(status: .ERROR, data: data, statusCode: statusCode))
            return
        }
        
        completion(NetworkResult(status: .SUCCESS, data: data, statusCode: statusCode))
    }
}
