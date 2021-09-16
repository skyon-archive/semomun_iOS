//
//  Preview.swift
//  Preview
//
//  Created by qwer on 2021/09/11.
//

import Foundation

// { count, workbooks }
// { wid, title, image }

struct SearchPreview: Codable, CustomStringConvertible {
    var description: String {
        return "\(count), \(workbooks)"
    }
    
    var count: Int
    var workbooks: [Preview]
}

struct Preview: Codable, CustomStringConvertible {
    var description: String {
        return "\(wid), \(title), \(image)"
    }
    
    var wid: Int64
    var title: String
    var image: Data?
}
