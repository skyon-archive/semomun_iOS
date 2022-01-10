//
//  Network.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation
import Alamofire

protocol NetworkFetchable {
    static func get(url: String, param: [String: String], completion: @escaping (RequestResult) -> Void)
    static func post(url: String, param: [String: String], completion: @escaping(RequestResult) -> Void)
    static func put(url: String, param: [String: String], completion: @escaping(RequestResult) -> Void)
}

struct Network: NetworkFetchable {
    static func get(url: String, param: [String: String] = [:], completion: @escaping (RequestResult) -> Void) {
        print(url)
        AF.request(url, method: .get, parameters: param)
            .responseDecodable(of: String.self) { response in
                Self.toRequestResult(with: response, completion: completion)
            }.resume()
    }
    
    static func post(url: String, param: [String: String], completion: @escaping (RequestResult) -> Void) {
        print(url, param)
        AF.request(url, method: .post, parameters: param)
            .responseDecodable(of: String.self) { response in
                Self.toRequestResult(with: response, completion: completion)
            }.resume()
    }
    
    static func put(url: String, param: [String: String], completion: @escaping (RequestResult) -> Void) {
        print(url, param)
        AF.request(url, method: .put, parameters: param)
            .responseDecodable(of: String.self) { response in
                Self.toRequestResult(with: response, completion: completion)
            }.resume()
    }
    
    static func toRequestResult(with response: DataResponse<String, AFError>, completion: @escaping (RequestResult) -> Void) {
        let result = RequestResult(statusCode: response.response?.statusCode, data: response.data)
        print(response.response?.statusCode ?? 400)
        completion(result)
    }
}
