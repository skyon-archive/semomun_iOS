//
//  PreviewOfDB.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
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
    var description: String {
        return "(\(wid), \(title), \(bookcover))"
    }
    
    var wid: Int
    var title: String
    var bookcover: String
}
