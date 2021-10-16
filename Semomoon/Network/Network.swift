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
        AF.request(url, method: .get).responseJSON { response in
            switch response.result {
            case .success:
                completion(response.data)
            case .failure(let error):
                print("Error: \(error._code)")
                completion(nil)
            }
        }.resume()
    }

    static func post(url: String, param: [String: String], completion: @escaping(Data?) -> Void) {
        AF.request(url, method: .post, parameters: param).responseJSON { response in
            switch response.result {
            case .success:
                completion(response.data)
            case .failure(let error):
                print("Error: \(error._code)", error.localizedDescription, url)
                completion(nil)
            }
        }.resume()
    }
}
