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
    var workbooks: [Preview_dumy]
}

struct Preview: Codable, CustomStringConvertible {
    var description: String {
        return "\(wid), \(title), \(image)"
    }
    
    var wid: Int
    var title: String
    var image: Int?
}

struct Preview_dumy: Codable, CustomStringConvertible {
    var description: String {
        return "\(wid), \(title), \(image)"
    }
    
    var wid: Int
    var title: String
    var image: String?
}


class Preview_Real {
    var preview: Preview
    var imageData: Data?
    
    init(preview: Preview) {
        self.preview = preview
        guard let image = preview.image,
              let url = URL(string: "http://test/tmp/preview/\(image).png") else { return }
        do {
            try imageData = Data(contentsOf: url)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    init(wid: Int, title: String, image: Int?) {
        self.preview = Preview(wid: wid, title: title, image: image)
        guard let image = preview.image,
              let url = URL(string: "http://test/tmp/preview/\(image).png") else { return }
        do {
            try imageData = Data(contentsOf: url)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func setDumyData(data: Data) {
        self.imageData = data
    }
}
