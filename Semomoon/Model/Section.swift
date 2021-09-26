//
//  Section.swift
//  Section
//
//  Created by qwer on 2021/09/05.
//

import Foundation

struct Section: Codable {
    var sid: Int
    var wid: Int
    var index: Int
    var title: String
    var detail: String
    var image: String
    var cutoff: String
}

//class Section_Real {
//    var section: Section
//    var url: URL
//    var imageData: Data
//
//    init(section: Section) {
//        self.section = section
//        self.url = URL(string: "http://semomoonDB/tmp/section/\(section.image).png")!
//        self.imageData = Data()
////        loadImage()
//    }
//
//    func loadImage() {
//        do {
//            try self.imageData = Data(contentsOf: url)
//        } catch let error {
//            print(error.localizedDescription)
//        }
//    }
//}
