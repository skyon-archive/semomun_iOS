//
//  Preview.swift
//  Semomoon
//
//  Created by qwer on 2021/10/03.
//

import Foundation

struct SearchPreview: Codable, CustomStringConvertible {
    var description: String {
        return "\(count), \(workbooks)"
    }
    
    var count: Int
    var workbooks: [PreviewOfDB]
}

struct PreviewOfDB: Codable, CustomStringConvertible {
    var wid: Int
    var title: String
    var image: String
    
    var description: String {
        return "(\(wid), \(title), \(image))"
    }
}
