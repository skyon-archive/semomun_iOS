//
//  QueryListButton.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/27.
//

import Foundation

struct CategoryQueryButtons: Codable, CustomStringConvertible {
    var description: String {
        return ""
    }
    
    var queryButtons: [QueryListButton]
    
    func getJsonString() -> String? {
        let jsonEncoder = JSONEncoder()
        guard let jsonData = try? jsonEncoder.encode(self) else { return nil }
        guard let jsonStringData = String(data: jsonData, encoding: String.Encoding.utf8) else { return nil }
        return jsonStringData
    }
}

struct QueryListButton: Codable, CustomStringConvertible {
    var description: String {
        return "\(queryTitle), \(queryItems)"
    }
    
    var queryTitle: String
    var queryItems: [String]
}
