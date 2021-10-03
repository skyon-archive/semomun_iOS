//
//  Workbook.swift
//  Workbook
//
//  Created by qwer on 2021/09/05.
//

import Foundation

class Workbook_Real {
    var workBook: WorkbookOfDB
    var url: URL
    var imageData: Data
    
    init(workBook: WorkbookOfDB) {
        self.workBook = workBook
        self.url = URL(string: workBook.image)!
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
        let preview = PreviewOfDB(wid: workBook.wid, title: workBook.title, image: workBook.image)
        return preview
    }
}
