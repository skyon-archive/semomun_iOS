//
//  Network.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation
import Alamofire

class Network {
    static func get(url: String, completion: @escaping (RequestResult) -> Void) {
        print(url)
        AF.request(url, method: .get).responseJSON { response in
            let result = RequestResult(statusCode: response.response?.statusCode, data: response.data)
            print(response.response?.statusCode)
            completion(result)
        }.resume()
    }
    
    static func get(url: URL, completion: @escaping(Data?) -> Void) {
        AF.request(url, method: .get).responseData { response in
            switch response.result {
            case .success:
                completion(response.data)
            case .failure(let error):
                print("Error: \(error._code)")
                completion(nil)
            }
        }.resume()
    }
    
    static func getWithQeuryItems(url: String, param: [String: String], completion: @escaping(RequestResult) -> Void) {
        let queryItems = param.map { URLQueryItem(name: $0.key, value: $0.value ) }
        guard var components = URLComponents(string: url) else { return }
        components.queryItems = queryItems
        guard let dbURL = components.url else { return }
        print(dbURL.relativeString)
        
        let request = URLRequest(url: dbURL)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let response = response as? HTTPURLResponse else {
                print("Error: response")
                let result = RequestResult(statusCode: 400, data: nil)
                completion(result)
                return
            }
            let result = RequestResult(statusCode: response.statusCode, data: data)
            completion(result)
        }
        task.resume()
    }
    
//    static func getWithBody(url: String, param: [String: String], completion: @escaping(RequestResult) -> Void) {
//        print(url, param)
//        guard let url = URL(string: url) else { return }
//        let jsonData = try? JSONSerialization.data(withJSONObject: param)
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.httpBody = jsonData
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let response = response as? HTTPURLResponse else {
//                print("Error: response")
//                let result = RequestResult(statusCode: 400, data: nil)
//                completion(result)
//                return
//            }
//            let result = RequestResult(statusCode: response.statusCode, data: data)
//            completion(result)
//        }
//        task.resume()
//    }

    static func post(url: String, param: [String: String], completion: @escaping(RequestResult) -> Void) {
        print(url, param)
        AF.request(url, method: .post, parameters: param).responseJSON { response in
            let result = RequestResult(statusCode: response.response?.statusCode, data: response.data)
            print(response.response?.statusCode)
            completion(result)
        }.resume()
    }
}
