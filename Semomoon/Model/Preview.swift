//
//  Preview.swift
//  Preview
//
//  Created by qwer on 2021/09/11.
//

import Foundation

struct Preview: Codable {
    var wid: Int
    var title: String
    var image: Int
}

class Preview_Real {
    var preview: Preview
    var url: URL
    var imageData: Data
    
    init(preview: Preview) {
        self.preview = preview
        self.url = URL(string: "http://test/tmp/preview/\(preview.image).png")!
        self.imageData = Data()
//        loadImage()
    }
    
    func loadImage() {
        do {
            try self.imageData = Data(contentsOf: url)
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
