//
//  Preview.swift
//  Semomoon
//
//  Created by Kang Minsang on 2021/09/11.
//

import Foundation

struct Preview_loaded {
    var wid: Int
    var title: String
    var image: Data = Data()
    
    init(preview: PreviewOfDB) {
        self.wid = preview.wid
        self.title = preview.title
    }
}
