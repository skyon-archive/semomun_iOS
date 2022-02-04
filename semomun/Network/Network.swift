//
//  Network.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation
import Alamofire

struct Network: NetworkFetchable {
    func get(url: String, param: [String: String]?, completion: @escaping (RequestResult) -> Void) {
        let param = param != nil ? param : [:]
        print("\(url), \(optional: param)")
        AF.request(url, method: .get, parameters: param) { $0.timeoutInterval = .infinity }
            .responseDecodable(of: String.self) { response in
                self.toRequestResult(with: response, completion: completion)
            }.resume()
    }
    
    func post(url: String, param: [String: String], completion: @escaping (RequestResult) -> Void) {
        print(url, param)
        AF.request(url, method: .post, parameters: param)  { $0.timeoutInterval = .infinity }
            .responseDecodable(of: String.self) { response in
                self.toRequestResult(with: response, completion: completion)
            }.resume()
    }
    
    func put(url: String, param: [String: String], completion: @escaping (RequestResult) -> Void) {
        print(url, param)
        AF.request(url, method: .put, parameters: param)  { $0.timeoutInterval = .infinity }
            .responseDecodable(of: String.self) { response in
                self.toRequestResult(with: response, completion: completion)
            }.resume()
    }
    
    private func toRequestResult(with response: DataResponse<String, AFError>, completion: @escaping (RequestResult) -> Void) {
        let result = RequestResult(statusCode: response.response?.statusCode, data: response.data)
        print(response.response?.statusCode ?? 400)
        completion(result)
    }
}
