//
//  Preview.swift
//  Preview
//
//  Created by qwer on 2021/09/11.
//

import Foundation

struct SearchPreview: Codable, CustomStringConvertible {
    var description: String {
        return "\(count), \(workbooks)"
    }
    
    var count: Int
    var workbooks: [Preview]
}

struct Preview: Codable, CustomStringConvertible {
    var wid: Int
    var title: String
    var image: String
    
    var description: String {
        return "(\(wid), \(title), \(image))"
    }
}

struct Preview_loaded {
    var wid: Int
    var title: String
    var image: Data = Data()
    
    init(preview: Preview) {
        self.wid = preview.wid
        self.title = preview.title
    }
    
//    mutating
}
