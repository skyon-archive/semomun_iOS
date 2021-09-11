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
    
    init(wid: Int, title: String, image: Int) {
        self.preview = Preview(wid: wid, title: title, image: image)
        self.url = URL(string: "http://test/tmp/preview/\(image).png")!
        self.imageData = Data()
    }
    
    func loadImage() {
        do {
            try self.imageData = Data(contentsOf: url)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func setDumyData(data: Data) {
        self.imageData = data
    }
}
