//
//  Section.swift
//  Section
//
//  Created by qwer on 2021/09/05.
//

import Foundation

struct Section: Codable {
    var sid: Int //섹션 고유의 번호
    var wid: Int //섹션이 속한 Workbook 의 wid
    var index: Int //섹션의 순서
    var title: String //색션의 제목
    var detail: Int //섹션의 정보
    var image: Int //섹션의 표지 이미지
    var cutoff: String //등급 컷 관련 정보 (json)
}

class Section_Real {
    var section: Section
    var url: URL
    var imageData: Data
    
    init(section: Section) {
        self.section = section
        self.url = URL(string: "http://semomoonDB/tmp/section/\(section.image).png")!
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
