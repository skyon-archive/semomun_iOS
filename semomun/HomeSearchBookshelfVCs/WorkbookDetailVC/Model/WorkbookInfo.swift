//
//  WorkbookInfo.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/14.
//

import Foundation

struct WorkbookInfo {
    let title: String
    let author: String
    let publisher: String
    var releaseDate: String
    let fileSize: String
    let isbn: String
    let price: Int
    let imageData: Data?
    
    init(previewCore: Preview_Core) {
        self.title = previewCore.title ?? "문제집 제목 없음"
        self.author = previewCore.author ?? "저자 정보 없음"
        self.publisher = previewCore.publisher ?? "출판사 정보 없음"
        self.releaseDate = previewCore.date?.koreanYearMonthDayText ?? "출판일 정보 없음"
        self.fileSize = "\(previewCore.size)MB"
        self.isbn = previewCore.isbn ?? ""
        self.price = Int(previewCore.price)
        self.imageData = previewCore.image
    }
    
    init(workbookDTO: WorkbookOfDB) {
        let sectionInfos = workbookDTO.sections
        self.title = workbookDTO.title
        self.author = workbookDTO.author
        self.publisher = workbookDTO.publishCompany
        self.releaseDate = workbookDTO.publishdDate.koreanYearMonthDayText
        self.fileSize = "\(sectionInfos.reduce(0, { $0 + $1.fileSize }))MB"
        self.isbn = workbookDTO.isbn
        self.price = workbookDTO.price
        self.imageData = nil
    }
}
