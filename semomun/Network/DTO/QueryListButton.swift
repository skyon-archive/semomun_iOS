//
//  QueryListButton.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/27.
//

import Foundation

struct CategoryQueryButtons: Codable, CustomStringConvertible {
    var description: String {
        return "\(self.queryButtons.map { $0.title })"
    }
    
    var queryButtons: [QueryListButton]
    
    func getJsonString() -> String? {
        let jsonEncoder = JSONEncoder()
        guard let jsonData = try? jsonEncoder.encode(self) else { return nil }
        guard let jsonStringData = String(data: jsonData, encoding: String.Encoding.utf8) else { return nil }
        return jsonStringData
    }
}

struct QueryListButton: Codable {
    var title: String
    var menus: [String]
    var queryParamKey: String
    var queryParamValues: [String]
}
