//
//  Workbook.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import Foundation

class Workbook_Real {
    var workBook: WorkbookOfDB
    var url: URL
    var imageData: Data
    
    init(workBook: WorkbookOfDB) {
        self.workBook = workBook
        self.url = URL(string: workBook.bookcover)!
        self.imageData = Data()
        loadImage()
    }
    
    func loadImage() {
        do {
            try self.imageData = Data(contentsOf: url)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func convertToPreview() -> PreviewOfDB {
        let preview = PreviewOfDB(wid: workBook.wid, title: workBook.title, bookcover: workBook.bookcover)
        return preview
    }
}
