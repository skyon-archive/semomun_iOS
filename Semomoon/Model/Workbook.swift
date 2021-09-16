//
//  Workbook.swift
//  Workbook
//
//  Created by qwer on 2021/09/05.
//

import Foundation

struct Workbook: Codable {
    var wid: Int64 //문제집 고유 번호
    var title: String
    var image: Data? //문제집 표지 이미지
    var year: Int //출판연도
    var month: Int //출판 달
    var price: Int //가격(원)
    var detail: String //문제집 정보
    var sales: Int //문제집 판매량
    var publisher: String //문제집 출판사
    var category: String //문제집 유형
    var subject: String //문제집 주제
    
    func preview() -> Preview_Core {
//        let preview = Preview_Real(wid: wid, title: title, image: Data())
        let preview = Preview_Core()
        preview.preview2core(wid: wid, title: title, image: image)
        return preview
    }
}

class Workbook_Real {
    var workBook: Workbook
    var url: URL
    var imageData: Data
    
    init(workBook: Workbook) {
        self.workBook = workBook
        self.url = URL(string: "http://\(123123)/tmp/workbook/\(workBook.image).png")!
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
    
    func convertToPreview() -> Preview {
        let preview = Preview(wid: workBook.wid, title: workBook.title, image: workBook.image)
        return preview
    }
}
