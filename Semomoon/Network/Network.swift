//
//  Network.swift
//  Semomoon
//
//  Created by FreeDeveloper97 on 2021/10/11.
//

import Foundation
import Alamofire

class Network {
    static func get(url: String, completion: @escaping (Data?) -> Void) {
        print(url)
        AF.request(url, method: .get).responseJSON { response in
            switch response.result {
            case .success:
                print(String(data: response.data!, encoding: .utf8))
                completion(response.data)
            case .failure(let error):
                print("Error: \(error._code)")
                completion(nil)
            }
        }.resume()
    }

    static func post(url: String, param: [String: String], completion: @escaping(Data?) -> Void) {
        print(url, param)
        
        var queryItems: [URLQueryItem] = []
        param.forEach {
            queryItems.append(URLQueryItem(name: $0.key, value: $0.value))
        }
        guard let url = URL(string: url) else { return }
        
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                return
            }
            print(String(data: data, encoding: .utf8))
            completion(data)
        }
        task.resume()
        
        
        
        
        
//        AF.request(url, method: .post, parameters: param).responseJSON { response in
//            switch response.result {
//            case .success:
//                print(String(data: response.data!, encoding: .utf8))
//                completion(response.data)
//            case .failure(let error):
//                print("Error: \(error._code)", error.localizedDescription, url)
//                completion(nil)
//            }
//        }.resume()
    }
}
